//
//  MenuListView.swift
//  Menu
//
//  Created by Andreas Verhoeven on 08/01/2025.
//

import UIKit
import CoreFoundation
import AveDataSource

/// This view is what is seen as a "menu": either a main menu or a sub menu.
/// It renders the elements that are assigned, as well as the shadow and blur view.
///
/// The elements are rendered using two `ElementsListView`s: one for the
/// header items and one for the main items.
class MenuListView: UIView {
	// MARK: Views
	/// our shadow, extending beyond our bounds
	let shadowView = CutoutShadowView()
	/// clips the view into a round rect
	let clipView = UIView()
	/// our blurry background, goes into the clipview
	let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
	/// holds our actual contents, goes into the clipview on top of the background view
	let contentView = UIView()
	/// our header elements
	let headerElementsListView = ElementsListView()
	/// our main elements
	let mainElementsListView = ElementsListView()

	// MARK: Bookkeeping
	var parentMenuListView: MenuListView?

	// MARK: Callbacks
	/// keep a reference to the menu view we are embedded in, so we can report
	/// when it needs to update it's size
	weak var menuView: MenuView?
	var updateCallback: ((_ animated: Bool) -> Void)?

	// MARK: PresentationIdentifiers
	let presentationIdentifier = UUID().uuidString

	// MARK: SubMenu
	var menu: Menu? {
		didSet {
			update(animated: false)
		}
	}
	var isSubMenu: Bool { parentMenuListView != nil }

	// MARK: Animation State
	/// true if we are being dismissed - used by the `MenuView` to keep track of
	/// what's happening
	var isBeingDismissed = false

	var isFullyMinimized = false
	var isSubMenuOpen = false {
		didSet {
			guard isSubMenuOpen != oldValue else { return }
			headerElementsListView.showsAsOpenedForMenuItem = (isSubMenuOpen == true ? subMenuHeaderElement : nil)
		}
	}

	var isPresented: Bool {
		return (isSubMenu == false || isSubMenuOpen == true)
	}

	/// This is a bit tricky, but since in the end we use a `UITableView` with AutoLayout, we need
	/// the tableview to be a bit bigger than it can actually be, so that it had rendered enough cells
	/// to know at least a minimum size. We try to be the same size as the screen height more-or-less,
	/// but this is determined by `MenuView`: this is just to pass that value along.
	var maximumHeight: CGFloat = 835 {
		didSet {
			headerElementsListView.maximumHeight = maximumHeight
			mainElementsListView.maximumHeight = maximumHeight
		}
	}

	/// if true, we'll invert our main element order - happens when we're presenting
	/// from bottom to top (and no override is set)
	var shouldInvertElementOrder = false

	/// the id of the menu item that's should be highlighted
	var highlightedMenuElementId: MenuElement.ID? {
		didSet {
			headerElementsListView.highlightedMenuElementId = highlightedMenuElementId
			mainElementsListView.highlightedMenuElementId = highlightedMenuElementId
		}
	}

	// MARK: Coordinates <-> Item
	/// Describes the frame of an element: it's full frame and it's visible frame
	struct ElementFrame {
		var frame: CGRect
		var visibleFrame: CGRect

		var lengthOfObscuredAtTop: CGFloat {
			return visibleFrame.minY - frame.minY
		}

		static func with(frame: CGRect) -> Self {
			Self(frame: frame, visibleFrame: frame)
		}

		func convert(from: UIView, to: UIView) -> Self {
			return Self(
				frame: from.convert(frame, to: to),
				visibleFrame: from.convert(visibleFrame, to: to)
			)
		}
	}

	/// Gets the ElementFrame in `MenuListView` coordinates for menu item by id - returns `nil` if there's no such item.
	func frame(for menuItemId: MenuElement.ID?) -> ElementFrame? {
		if let frame = mainElementsListView.frame(for: menuItemId) {
			return frame.convert(from: mainElementsListView, to: self)
		}

		if let frame = headerElementsListView.frame(for: menuItemId) {
			return frame.convert(from: headerElementsListView, to: self)
		}

		return nil
	}

	/// Gets the menu item at given point, if it exists
	func menuItem(at point: CGPoint) -> MenuElement? {
		return mainElementsListView.menuItem(at: mainElementsListView.convert(point, from: self)) ?? headerElementsListView.menuItem(at: headerElementsListView.convert(point, from: self))
	}

	func stopScrolling() {
		headerElementsListView.stopScrolling()
		mainElementsListView.stopScrolling()
	}

	func cleanupAfterDisplay() {
		cleanupDisplayedElements()
		menu?.cleanupAfterMenuDisplay()
	}

	// MARK: - Privates
	private var isPendingUpdate = false
	private lazy var subMenuHeaderElement = menu.flatMap { SubMenuHeaderElement(menu: $0, parentPresentationIdentifier: parentMenuListView?.presentationIdentifier) } ?? nil

	private var displayedElementIds = Set<MenuElement.ID>()
	private var displayedElements = [WeakElement]()

	struct WeakElement {
		weak var element: MenuElement?
	}

	private func update(animated: Bool) {
		// clear our pending flag, if it was set
		isPendingUpdate = false

		guard let menu else { return }

		registerElementsAsDisplayed(menu.children)
		registerElementsAsDisplayed(menu.headers)

		menu.children.forEach { $0.delegate = self }

		let properties = MenuProperties(isInAccessibilityMode: traitCollection.preferredContentSizeCategory.isAccessibilityCategory)
		var childrenLeafs = menu.childrenLeafs(hasMenuHeader: isSubMenu, properties: properties)
		var headerLeafs = menu.headerLeafs(properties: properties)

		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory == true || traitCollection.verticalSizeClass == .compact {
			childrenLeafs = headerLeafs + childrenLeafs
			headerLeafs = []
		}

		if isSubMenu == true, let subMenuHeaderElement {
			headerLeafs.insert(subMenuHeaderElement, at: 0)
		}

		registerElementsAsDisplayed(childrenLeafs)
		registerElementsAsDisplayed(headerLeafs)

		let presentedChildrenElements = childrenLeafs.map { PresentedMenuElement(element: $0) }
		let presentedHeaderElements = headerLeafs.map { PresentedMenuElement(element: $0) }

		headerElementsListView.lastHeaderItemCanHaveSeparator = (childrenLeafs.first?.canShowSeparator == true)
		headerElementsListView.isSubMenu = isSubMenu
		mainElementsListView.isSubMenu = isSubMenu

		headerElementsListView.update(items: presentedHeaderElements, animated: animated)
		mainElementsListView.update(items: presentedChildrenElements, animated: animated)

		setNeedsLayout()
		updateCallback?(animated)
	}

	private func registerElementsAsDisplayed(_ elements: [MenuElement]) {
		for element in elements {
			registerElementAsDisplayed(element)
		}
	}

	private func registerElementAsDisplayed(_ element: MenuElement) {
		let elementId = element.id
		element.delegate = self

		guard displayedElementIds.contains(elementId) == false else { return }
		displayedElementIds.insert(elementId)
		displayedElements.append(WeakElement(element: element))

		element.prepareForDisplayInMenu(properties: MenuProperties())
	}

	private func cleanupDisplayedElements() {
		for weakElement in displayedElements {
			weakElement.element?.cleanupAfterDisplay()
		}
		displayedElements.removeAll()
		displayedElementIds.removeAll()
	}

	// MARK: - UIView
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setNeedsLayout()
		update(animated: false)
	}

	override var intrinsicContentSize: CGSize {
		setNeedsLayout()
		layoutIfNeeded()

		// pretty simple: the height we want to be is the combined height of the header and main lists
		return CGSize(
			width: UIView.noIntrinsicMetric,
			height: headerElementsListView.intrinsicContentSize.height + mainElementsListView.intrinsicContentSize.height
		)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		// the framer for our content
		let contentFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

		// the shadow is insetted so that it extends beyonds our bounds
		let shadowInset = shadowView.shadowSize
		shadowView.frame = contentFrame.insetBy(dx: -shadowInset, dy: -shadowInset)

		// the content view can be transformed, so update it's frame by ignoring the transform
		contentView.frameIgnoringTransform = contentFrame
		clipView.frame = contentFrame
		backgroundView.frame = contentFrame

		// the header and main list are stacked: the main list can be scrollable if needed
		let headerHeight = headerElementsListView.intrinsicContentSize.height
		UIView.performWithoutAnimation {
			headerElementsListView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: headerHeight)
			mainElementsListView.frame = CGRect(x: 0, y: headerHeight, width: bounds.width, height: max(0, bounds.height - headerHeight))
		}

		headerElementsListView.layoutIfNeeded()
		mainElementsListView.layoutIfNeeded()

		// we want to inset the scroll indicators so that they don't cover the rounded corner:
		// need to take into account the height of the various lists.
		let cornerRadius = shadowView.cornerRadius
		headerElementsListView.tableView.verticalScrollIndicatorInsets = UIEdgeInsets(
			top: min(cornerRadius, headerElementsListView.bounds.height),
			left: 0,
			bottom: headerElementsListView.tableView.contentInset.bottom + max(0, cornerRadius - mainElementsListView.bounds.height),
			right: 0
		)
		mainElementsListView.tableView.verticalScrollIndicatorInsets = UIEdgeInsets(
			top: max(0, cornerRadius - headerElementsListView.bounds.height),
			left: 0,
			bottom: mainElementsListView.tableView.contentInset.bottom + cornerRadius,
			right: 0
		)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		clipView.clipsToBounds = true
		clipView.layer.cornerRadius = shadowView.cornerRadius
		
		backgroundView.presentationIdentifier = presentationIdentifier

		addSubview(shadowView)
		addSubview(clipView)
		clipView.addSubview(backgroundView)
		clipView.addSubview(contentView)

		// this is needed so that our separators don't disappear when
		// changing the alpha value of `contentView`
		layer.allowsGroupOpacity = false
		contentView.layer.allowsGroupOpacity = false

		// we do some magic
		headerElementsListView.isHeader = true
		mainElementsListView.hasScrolledPastTopChangeCallback = { [weak self] in
			guard let self else { return }
			headerElementsListView.shouldLastHeaderItemHaveSeparator = mainElementsListView.isScrolledPastTop
			headerElementsListView.updateLastHeaderCellSeparator(animated: true)
		}
		contentView.addSubview(headerElementsListView)
		contentView.addSubview(mainElementsListView)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
}

extension MenuListView: MenuElementDelegate {
	func updateImmediately() {
		guard window != nil else { return }
		update(animated: true)
	}

	func setNeedsUpdate() {
		guard isPendingUpdate == false else { return }

		// we got requested to update ourselves, but we want to
		// debounce until the next runloop, since more changes might come in
		isPendingUpdate = true

		let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault().takeUnretainedValue(), CFRunLoopActivity.beforeWaiting.rawValue, false, 0) { [weak self] observer, activity in
			guard let self else { return }
			guard isPendingUpdate == true else { return }
			updateImmediately()
		}

		if let observer {
			CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
		}
	}

	func toggleSubMenu(_ subMenu: Menu) {
		menuView?.toggleSubMenu(subMenu, from: self)
	}

	func registerElement(_ element: MenuElement) {
		registerElementAsDisplayed(element)
	}

	func registerScrollView(_ scrollView: UIScrollView) {
		menuView?.registerScrollView(scrollView)
	}
}
