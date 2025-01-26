//
//  MenuView.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience
import ObjectiveC.runtime

/// This encapsulates showing, presenting and interacting with
/// menus and submenus.
///
/// This view is supposed to be presented fullscreen: it'll
/// automatically place the menus in the right spot. Each (sub)menu is
/// represented by a `MenuListView`, stacked on top of each other.
///
/// A `Menu` is presented by presenting a `MenuOverlayViewController`
/// which in turn adds a `MenuView` fullscreen to its window, above everything else:
/// and drives the animation from the `viewDidAppear()` and `viewWillDisappear()`
/// methods.
/// Since the `MenuView` is not part of the view controller, we have easy interuptable animations.
class MenuView: UIView {
	/// The menu items to present
	var menu: Menu?

	// MARK: SourceView
	/// the `view` that is presenting this menu and to
	/// which we should attach
	var sourceView: UIView?

	/// the rectangle to use from `sourceView`, in
	/// `sourceView` coordinates
	var sourceRect: CGRect?

	/// the attachment point __in__ `sourceView` coordinates
	/// this is where the menu will attach to
	var menuAttachmentPoint: CGPoint = .zero

	// MARK: Options
	/// the order the menu is in: if the menu is presented from bottom-to-top, by default
	/// we swap around the order so that the first item is closest to the `sourceView`:
	///
	var preferredElementOrder: Menu.ElementOrder = .automatic

	/// you can transfer a long press gesture to this view as selection, so the user can long press and pan to select directly, without lifting fingers
	func transferLongPressGestureRecognizer(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
		guard longPressGestureRecognizer.state == .changed || longPressGestureRecognizer.state == .began else { return }
		stopTransferringLongPressGestureRecognizer()
		longPressGestureRecognizer.addTarget(self, action: #selector(highlightingGestureRecognizerFired(_:)))
		transferredLongPressGestureRecognizer = longPressGestureRecognizer

		isHighlightingGestureInFlight = true
		highlightedMenuItem = nil
		highlightingFeedbackGenerator = nil

		// find out where we started
		startedHighlightingInsideMenu = true
		highlightingStartPoint = longPressGestureRecognizer.location(in: longPressGestureRecognizer.view?.window)

		// update our selection
		updateHighlightedMenuItemFromGesture()

		// and __after__ that start the haptic generator, so that we don't
		// do a haptic feedback on the initial selection
		highlightingFeedbackGenerator = UISelectionFeedbackGenerator()
		highlightingFeedbackGenerator?.prepare()
	}

	func stopTransferringLongPressGestureRecognizer() {
		guard let transferredLongPressGestureRecognizer else { return }
		transferredLongPressGestureRecognizer.removeTarget(self, action: #selector(highlightingGestureRecognizerFired(_:)))
		self.transferredLongPressGestureRecognizer = nil
	}

	// MARK: Callbacks
	/// callbacks used internally
	var dismissalCallback: (() -> Void)?
	var willDismissCallback: ((Bool) -> Void)?

	// MARK: Presentation And Dismissal

	/// this will present the menu for the first time
	func present(animated: Bool) {
		determineDirectionAndAlignment()
		guard let menu else { return }
		addMenu(menu, animated: animated)
	}

	/// this will perform a dismissal animation of the full menu.
	func performDismiss(animated: Bool, completion: @escaping () -> Void) {
		guard isFullDismissal == false else { return }

		stopTransferringLongPressGestureRecognizer()
		dismissalCallback?()

		isUserInteractionEnabled = false
		animateIfNeeded(animated: animated, animations: { [self] in
			isFullDismissal = true
			for menuListView in menuListViews {
				menuListView.isFullyMinimized = true
				hostingView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
			}
			updateMenuViews()
		}, completion: { [self] in
			for menuListView in menuListViews {
				menuListView.cleanupAfterDisplay()
			}
			menu?.cleanupAfterDisplay()
			completion()
		})
	}

	/// this will dismiss the menu, by asking the callback to do it if possible
	func dismiss(animated: Bool) {
		if let willDismissCallback {
			willDismissCallback(animated)
		} else {
			dismiss(animated: animated)
		}
	}

	func toggleSubMenu(_ menu: Menu, from menuListView: MenuListView) {
		if let existingSubMenuListView = menuListViews.first(where: { $0.menu === menu && $0.isSubMenu == true }) {
			if existingSubMenuListView.isSubMenuOpen == false && existingSubMenuListView.isBeingDismissed == true {
				// we're dismissing an existing menu, revert it
				animateIfNeeded(animated: true) {
					existingSubMenuListView.isBeingDismissed = false
					existingSubMenuListView.isSubMenuOpen = true
					self.updateMenuViews()
				}
			} else {
				dismissTopMostSubMenu()
			}
		} else {
			// no existing menu, add it
			addMenu(menu, animated: true)
		}
	}

	func dismissTopMostSubMenu() {
		guard let menuListView = menuListViews.last else { return }
		guard menuListView.isSubMenu == true else { return }
		guard menuListView.isBeingDismissed == false else { return }

		menuListView.endEditing(true)

		// we have an existing sub menu that is fully presented, dismiss it
		animateIfNeeded(animated: true, animations: {
			menuListView.isSubMenuOpen = false
			menuListView.isBeingDismissed = true
			self.updateMenuViews()
		}, completion: { [weak self] in
			guard let self else { return }
			if menuListView.isBeingDismissed == true {
				menuListViews.removeAll { $0 === menuListView }
				menuListView.removeFromSuperview()
				menuListView.cleanupAfterDisplay()
				updateHighlightedMenuItemIfNeeded()
			}
		})
	}

	// MARK: - Input
	@objc private func highlightingGestureRecognizerFired(_ sender: UILongPressGestureRecognizer) {
		switch sender.state {
			case .possible:
				break

			case .began:
				// the user touched down their fingers on our view and could possibly be highlighing stuff,
				// *BUT* they could also be scrolling in the `MenuListView` that is scrollable.
				//
				// We let both gesture recognizer run at the same time and stop the other one
				// if we are certain of the users intent:
				//  - if the user moves their finger outside of the current menu, we stop scrolling
				//  - if the scroll view scrolls (recognizes pans) we stop highlighting
				//
				// If the user started the gesture outside of the menu, we don't highlight but dismiss
				// after some small movement

				stopTransferringLongPressGestureRecognizer()

				// reset our selection
				isHighlightingGestureInFlight = true
				highlightedMenuItem = nil
				highlightingFeedbackGenerator = nil

				// find out where we started
				startedHighlightingInsideMenu = (menuListViewForhighlightingGestureRecognizer() != nil)
				highlightingStartPoint = sender.location(in: self)

				// update our selection
				updateHighlightedMenuItemFromGesture()

				// and __after__ that start the haptic generator, so that we don't
				// do a haptic feedback on the initial selection
				highlightingFeedbackGenerator = UISelectionFeedbackGenerator()
				highlightingFeedbackGenerator?.prepare()

			case .changed:
				if startedHighlightingInsideMenu == true {
					// we're highlighting: update the current highlighted item
					updateHighlightedMenuItemFromGesture()
				} else {
					// started a touch outside the menu, this will dismiss on touch up,
					// but check if we can already dismiss if the user moved a little bit
					let point = sender.location(in: self)
					let treshold = CGFloat(8)
					if abs(highlightingStartPoint.x - point.x) > treshold || abs(highlightingStartPoint.y - point.y) > treshold {
						dismiss(animated: true)
					}
				}

			case .ended:
				/// the highlighing gesture ended, process that
				endHighlightingGesture(didEndNormally: true)

				// if we didn't start inside the menu, this is a tap outside of the menu
				// in which case we just dismiss the whole menu
				guard startedHighlightingInsideMenu == true else { return dismiss(animated: true) }

				if let menuListView = menuListViewForhighlightingGestureRecognizer() {
					// if we're not inside the current menu, dismiss the top menu
					guard menuListView == currentMenuListView else {
						unscaleMenu()
						return dismissTopMostSubMenu()
					}

					// find the menu item that is currently highlighted and try to invoke it
					guard let menuItem = menuItemFromSelectionGesture() else { return }
					if menuItem.keepsMenuPresentedOnPerform == false {
						// if we don't need to keep the menu around, dismiss it already
						// so that our view controller is gone before a handler()
						// possibly tries to present another view controller.
						if currentMenuListView?.menu?.onlyDismissesSubMenu == true && currentMenuListView?.isSubMenu == true {
							dismissTopMostSubMenu()
						} else {
							dismiss(animated: true)
						}
					} else {
						// we keep the menu around, just unhiglight the menu item
						// and unscale the menu so it's back to normal
						highlightedMenuItem = nil
						unscaleMenu()
					}
					// finally, invoke the menu item: this could open
					// a submenu, or invoke a handler
					menuItem.perform()
				} else {
					unscaleMenu()
				}
				stopTransferringLongPressGestureRecognizer()

			case .cancelled, .failed:
				// gesture got cancelled, reset everything back to normal as if nothing happened
				endHighlightingGesture(didEndNormally: false)
				stopTransferringLongPressGestureRecognizer()

			@unknown default:
				break
		}
	}

	@objc private func handleScrollViewPanGestureRecognizer(_ sender: UIGestureRecognizer) {
		// The user scrolled, so stop recognizing our highlighing gesture
		highlightingGestureRecognizer.stopRecognizing()
		endHighlightingGesture(didEndNormally: false)
	}

	// MARK: - Internal
	internal func registerScrollView(_ scrollView: UIScrollView) {
		guard scrollView.registrationIdentifier != identifier else { return }
		scrollView.registrationIdentifier = identifier
		scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollViewPanGestureRecognizer(_:)))
	}

	// MARK: - Privates
	/// used for things
	private let identifier = UUID().uuidString

	/// the `MenuListView` of the (sub)menu that's currently on top of the list of (sub)menus
	/// and thus the one we interact with
	private var currentMenuListView: MenuListView? { menuListViews.last }

	/// true if we should invert the element order
	private var shouldInvertElementOrder: Bool {
		switch preferredElementOrder {
			case .automatic, .priority:
				return isMenuDirectedDownwards == true ? false : true

			case .fixed:
				return false
		}
	}

	/// The view that hosts our (sub)menus, sized to be the size of the biggest `MenuListView`
	private let hostingView = UIView()

	/// The stack of (sub)menus as `MenuListViews`.
	private var menuListViews = [MenuListView]()

	/// for when we're transfering gestures
	private weak var transferredLongPressGestureRecognizer: UILongPressGestureRecognizer?

	/// the horizontal direction we should align to
	private var horizontalAlignment = HorizontalAlignment.center

	private enum HorizontalAlignment {
		case leading
		case center
		case trailing
	}

	/// the vertical direction we should align to
	private var isMenuDirectedDownwards = true

	/// used to avoid the keyboard
	private var keyboardScreenFrame: CGRect?

	/// set if we're dismissing the full menu
	private var isFullDismissal = false

	// MARK: Highlighting
	/// the highlighted menu item - setting this will automatically update the UI and
	/// do a selection feedback if needed. It'll also start the autoInvoke timer
	/// so we can auto-invoke when highlighting the same item for a longer time
	private var highlightedMenuItem: MenuElement? {
		didSet {
			guard highlightedMenuItem?.id != oldValue?.id else { return }

			// if the highlighted item changed to another actual item,
			// provide some haptic feedback
			if highlightedMenuItem != nil {
				highlightingFeedbackGenerator?.selectionChanged()
			}

			updateHighlightingInMenuListViews()
			restartHighlightingAutoInvokeTimerIfNeeded()
		}
	}

	/// the gesture recognizer used for highlighting - we use a long press with 0 delay
	private lazy var highlightingGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(highlightingGestureRecognizerFired(_:)))

	/// keep track of where we started highlighting: if we started "highlighting" outside of the menu
	/// any small move will immediately dismiss the menu
	private var startedHighlightingInsideMenu = false

	/// the point in our view where we started highlighting - used to check if we did a `small`
	/// move as mentioned in `startedHighlightingInsideMenu`
	private var highlightingStartPoint = CGPoint.zero

	/// true if a highlighting gesture is currently going on
	private var isHighlightingGestureInFlight = false

	/// used to provide haptic feedback on selection __change__
	private var highlightingFeedbackGenerator: UISelectionFeedbackGenerator?

	/// timer used to check if we're highlighting the same item for a longer period of time
	/// and if we should auto-invoke the item
	private var highlightingAutoInvokeSubMenuTimer: Timer?

	/// the gesture recognizer to use for highlighting
	private var longPressGestureRecognizerToUse: UILongPressGestureRecognizer {
		return transferredLongPressGestureRecognizer ?? highlightingGestureRecognizer
	}

	/// Returns the `MenuListView` that the user is currently highlighting over
	private func menuListViewForhighlightingGestureRecognizer() -> MenuListView? {
		return menuListViews.reversed().first(where: { menuListView in
			let point = longPressGestureRecognizerToUse.location(in: menuListView)
			return menuListView.point(inside: point, with: nil)
		})
	}

	/// Updates the current `highlightedMenuItem` from the selection gesture
	private func updateHighlightedMenuItemFromGesture() {
		guard startedHighlightingInsideMenu == true else { return }
		guard let currentMenuListView else { return }

		let point = longPressGestureRecognizerToUse.location(in: currentMenuListView)
		let menuItem = currentMenuListView.menuItem(at: point)
		highlightedMenuItem = menuItem
		scaleMenuIfNeeded()
	}

	/// Updates the `highlightedMenuItem` if needed - Called when the layout
	/// of our menu changes, so that we can update what's under the users finger
	/// even if there's no movement and the gesture recognizer doesn't fire.
	private func updateHighlightedMenuItemIfNeeded() {
		guard isHighlightingGestureInFlight == true else { return }
		updateHighlightedMenuItemFromGesture()
	}

	/// Updates the highlighting in all our (sub)menu `MenuListView`s, so
	/// that the UI is up-to-date
	private func updateHighlightingInMenuListViews() {
		let currentMenuListView = self.currentMenuListView

		for menuListView in menuListViews {
			UIView.performWithoutAnimation {
				menuListView.highlightedMenuElementId = (currentMenuListView == menuListView ? highlightedMenuItem?.id : nil)
			}
		}
	}

	/// restarts the `auto invoke` timer if needed, to see if we hovered over the same
	/// item for long enough to auto invoke it.
	private func restartHighlightingAutoInvokeTimerIfNeeded() {
		highlightingAutoInvokeSubMenuTimer?.invalidate()
		highlightingAutoInvokeSubMenuTimer = nil

		guard highlightedMenuItem?.autoInvokeOnLongHighlighting == true else { return }

		let originalhighlightedMenuElementId = highlightedMenuItem?.id
		highlightingAutoInvokeSubMenuTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] timer in
			guard let self else { return }

			// The user has "hovered" over the same highlighted for long enough, try to auto-invoke
			// it if still needed
			guard let highlightedMenuItem else { return }
			guard highlightedMenuItem.id == originalhighlightedMenuElementId else { return }
			guard highlightedMenuItem.autoInvokeOnLongHighlighting == true else { return }

			// first, remove highlighting before invoking: that also clears the timer!
			self.highlightedMenuItem = nil
			highlightedMenuItem.perform()
		})
	}

	/// The menu item that's currently being "hovered over" according to the `highlightingGestureRecognizer`
	private func menuItemFromSelectionGesture() -> MenuElement? {
		guard let currentMenuListView else { return  nil}

		let point = longPressGestureRecognizerToUse.location(in: currentMenuListView)
		guard currentMenuListView.point(inside: point, with: nil) == true else { return nil }
		return currentMenuListView.menuItem(at: point)
	}

	/// Once the user moves it finger from inside->outside the menu, we scale it to signify to the user
	/// that there's no interaction: this takes care of that.
	private func scaleMenuIfNeeded() {
		let point = longPressGestureRecognizerToUse.location(in: self)
		var hostingViewFrame = hostingView.frameIgnoringTransform
		if transferredLongPressGestureRecognizer != nil {
			hostingViewFrame = hostingViewFrame.union(CGRect(origin: highlightingStartPoint, size: .zero))
		}

		if hostingViewFrame.contains(point) == false { //hostingView.point(inside: point, with: nil) == false {
			// we're outside of the menu, find out how much and than scale
			// based on how much we are out.
			let bounds = hostingViewFrame//hostingView.frame
			let dx = max(bounds.minX - point.x, 0, point.x - bounds.maxX)
			let dy = max(bounds.minY - point.y, 0, point.y - bounds.maxY)
			let distance = sqrt(dx*dx + dy*dy)

			// we're linearly scale: if you're 80pts outside the menu,
			// we scale down by 0.2
			let fractionalDistance = min(distance / 80, 1)
			let scale = 1.0 - fractionalDistance * 0.2

			// since we are scaling, that means the user moved from inside
			// to outside the menu: stop any potentional scrolling in the
			// top `MenuListView` so that we don't run both gestures at the same time.
			currentMenuListView?.stopScrolling()

			animateIfNeeded(animated: true) {
				self.hostingView.transform = CGAffineTransform(scaleX: scale, y: scale)
			}
		} else {
			// no scaling needed, unscale
			unscaleMenu()
		}
	}

	/// this scales back the menu to the original size, when the user moves outside -> inside or stops
	/// highlighting.
	private func unscaleMenu() {
		animateIfNeeded(animated: true) {
			self.hostingView.transform = .identity
		}
	}

	/// This ends highlighting
	private func endHighlightingGesture(didEndNormally: Bool) {
		isHighlightingGestureInFlight = false
		highlightingFeedbackGenerator = nil

		highlightingAutoInvokeSubMenuTimer?.invalidate()
		highlightingAutoInvokeSubMenuTimer = nil

		// if we ended normally, we don't want to unscale
		// and deselect, because the menu is __likely__ going
		// away anyways
		if didEndNormally == false {
			highlightedMenuItem = nil
			unscaleMenu()
		}
	}

	/// Returns the default anchor point for each direction
	private var defaultAnchorPoint: CGPoint {
		return CGPoint(x: 0.5, y: isMenuDirectedDownwards ? 0 : 1)
	}

	// MARK: - Layout
	/// the attachment point in self coordinates
	private var menuAttachmentPointInSelfCoordinates: CGPoint {
		guard let sourceView else { return menuAttachmentPoint }
		return sourceView.convert(menuAttachmentPoint, to: self)
	}

	/// the bounds inside our view that we can effectively use - not avoiding any keyboards
	private var unadjustedUsableBounds: CGRect {
		return bounds.inset(by: safeAreaInsets).insetBy(dx: 16, dy: 8)
	}

	/// the bounds inside our view that we can effectively use - avoids safe area and keyboard
	private var usableBounds: CGRect {
		var usableBounds = unadjustedUsableBounds

		// take the keyboard into account when figuring out our maximum height
		if let keyboardScreenFrame {
			let keyboardInView = convert(keyboardScreenFrame, from: nil)
			if usableBounds.maxY > keyboardInView.minY {
				usableBounds.size.height = keyboardInView.minY - usableBounds.minY - 16
			}
		}

		return usableBounds
	}

	private var isKeyboardAppearingUp: Bool {
		guard let keyboardScreenFrame else { return false }
		let keyboardInView = convert(keyboardScreenFrame, from: nil)
		return unadjustedUsableBounds.maxY > keyboardInView.minY
	}

	/// Returns the widht the menu should be
	private var menuWidth: CGFloat {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory == true {
			let maxWidth = bounds.inset(by: safeAreaInsets).width - 32
			return min(353, maxWidth)
		} else {
			return 250
		}
	}

	/// true if we should use the full available height, otherwise we limit the height
	private var shouldUseFullHeightAvailable: Bool {
		return (
			traitCollection.preferredContentSizeCategory.isAccessibilityCategory == true
			|| traitCollection.verticalSizeClass == .compact
			|| isKeyboardAppearingUp == true
		)
	}

	/// Updates all our (sub)menus layout and view properties
	private func updateMenuViews() {
		layoutMenus()
		updateMenuTransformsAndOpacity()
	}

	/// Does layout for our menus
	private func layoutMenus() {
		// the properties we use
		let usableBounds = usableBounds
		let maximumSingleMenuHeight = (shouldUseFullHeightAvailable == true ? usableBounds.height : usableBounds.height - 128)
		let menuWidth = menuWidth
		let inset = CGFloat(12)

		// Layout is a bit complicated because our menu can grown downwards or upwards.
		//
		// Downwards is relatively simple: if a sub-menu needs more space than it's parent,
		// we can simply extend the menu size: the absolute positions of parent views don't
		// change with a new sub menu. The main-menu will alwas be at y=0.
		//
		// Upwards is more complicated due to the fact that the whole menu grows upwards and
		// als that sub-menus open downwards, they are not reversed. So, we actually
		// don't know the full position until we know the size of each sub-menu:
		// it could be that a sub-menu is larger than it's parent, in which case menu
		// needs to grow upwards and the absolute positions need to be adjusted.
		//
		// To be able to do this, we have a two-step layout pass:
		// Step 1: we record the offset and height relative to the edge in which the
		//         menu doesn't grow.
		//		   for downwards growing menu it's relative to the top edge; However
		//		   for an upwards growing menu this means that the offset is relative
		//		   to the bottom edge.
		//
		// Step 2: Now that we know the relative positions, we know the absolute
		//         frames. For downwards growing this is simply `frame.y = offset`,
		//         but for upwards growing that will be `frame.y = totalHeight - offset`.


		/// This struct collects the wanted  offsets + heigts
		struct WantedLayout {
			/// the wanted offset from the anchoring edge
			var offset: CGFloat = 0
			/// the wanted height of the menu
			var height: CGFloat = 0

			/// the amount we need to offset the content, so that sub-menu "cell" to full menu presentations
			/// look correct
			var contentOffset: CGFloat = 0

			var farEndOffset: CGFloat { offset + height }
		}

		var wantedLayouts = [WantedLayout]()
		var currentWantedHeight = CGFloat(0)

		// iterate over each menu and calculate the wanted layout
		for (index, menuListView) in menuListViews.enumerated() {
			// Each presented sub-menu can use a smaller possible space, so
			// it looks like they are stacked.
			let insetToUse = inset * CGFloat(index)
			let allowedBounds = CGRect(origin: .zero, size: usableBounds.size).insetBy(dx: 0, dy: insetToUse)

			var wantedLayout = WantedLayout()

			if menuListView.isFullyMinimized == true {
				// We are fully minimized to the start or end appearance of the menu,
				// we are small and offsetted so sub-menus look stacked.
				wantedLayout.offset = insetToUse
				wantedLayout.height = CGFloat(110 - insetToUse)
			} else if menuListView.isSubMenu == false {
				// we're not a sub menu, so this is easy: we want to be the full possible height
				// and we are offsetted by the inset (should be 0 for the main-menu)
				wantedLayout.offset = insetToUse
				wantedLayout.height = min(maximumSingleMenuHeight, menuListView.intrinsicContentSize.height)
			} else {
				// Here things will get complicated. We are either:
				// - a submenu that is closed, we want to place ourselves at the exact position of the "submenu cell"
				//   in our parent menu
				// - a submenu that is opened, where we want the top of the menu to be aligned
				//   with the "submenu cell" in our parent menu, but also need to make more room if we don't fit
				//   in the rest of the space by moving the menu upwards relative to our parent.

				// first, check what the position of the "submenu cell" is in our parent
				let parentMenuListView = menuListViews[index - 1]

				// if we can't find this, we just default to the top of the parent
				let defaultItemElement = MenuListView.ElementFrame.with(frame: CGRect(x: 0, y: 0, width: menuWidth, height: 44))
				let parentItemElement = parentMenuListView.frame(for: menuListView.menu?.idForSubMenuElement) ?? defaultItemElement
				let positionOfParentItemElementInParentCoordinates = parentItemElement.visibleFrame.minY

				if menuListView.isSubMenuOpen == false {
					// Te sub menu is closed, we want to exactly line up to the visible frame of the parent:
					// our height is exactly the height of our parent item visible height.
					//
					// Yes, if the top of the parent item is obscured, we need to offset the content a bit
					// to line it up: that's where content offset comes in: we move the content up by the
					// amount that is obscured, so that we line up visually
					wantedLayout.height = parentItemElement.visibleFrame.height
					wantedLayout.contentOffset = -parentItemElement.lengthOfObscuredAtTop

					if isMenuDirectedDownwards == true {
						// if we're presented downwards, we need to adjust to the offset of our parent, which is simply
						// adding it's offset
						wantedLayout.offset = positionOfParentItemElementInParentCoordinates + wantedLayouts[index - 1].offset
					} else {
						// we are presented upwards, so we need take the position from the bottom
						wantedLayout.offset = wantedLayouts[index - 1].farEndOffset - positionOfParentItemElementInParentCoordinates - wantedLayout.height
					}

					//menuListView.clipView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
					menuListView.clipView.layer.cornerRadius = 0

				} else {
					// since we are full presented, our offset is calculated by seeing where it will be in the in the parent,
					// then we check how big the submenu wants to be and make sure it all fits
					let parentItemOffset = positionOfParentItemElementInParentCoordinates + wantedLayouts[index - 1].offset
					let wantedHeight = min(maximumSingleMenuHeight, menuListView.intrinsicContentSize.height)

					if isMenuDirectedDownwards == true {
						// going down is easy again, can't go past the bottom bounds
						wantedLayout.height = min(wantedHeight, maximumSingleMenuHeight, allowedBounds.height)
						wantedLayout.offset = min(max(allowedBounds.minY, parentItemOffset - inset), allowedBounds.maxY - wantedLayout.height, maximumSingleMenuHeight - wantedLayout.height)
					} else {
						// going up is a bit more complicated: calculate our offset in our view with an extra inset
						wantedLayout.height = min(wantedHeight, allowedBounds.height, maximumSingleMenuHeight)
						wantedLayout.offset = max(currentWantedHeight - parentItemOffset - wantedLayout.height + inset, insetToUse)
					}

					menuListView.clipView.layer.cornerRadius = 13
					//menuListView.clipView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
				}
			}

			currentWantedHeight = max(currentWantedHeight, wantedLayout.farEndOffset)
			wantedLayouts.append(wantedLayout)
		}

		// Now that we know where each menu should be, apply frames
		let totalMenuHeight = currentWantedHeight
		let menuAnchorPoint = defaultAnchorPoint
		for (menuListView, wantedLayout) in zip(menuListViews, wantedLayouts) {
			menuListView.layer.anchorPoint = menuAnchorPoint
			if isMenuDirectedDownwards == true {
				// downwards is easy: relative to top edge, so y starts at y = 0
				menuListView.frameIgnoringTransform = CGRect(x: 0, y: wantedLayout.offset, width: menuWidth, height: wantedLayout.height)
			} else {
				// upwards is relative to the bottom edge, so y = totalHeight - offset - height
				menuListView.frameIgnoringTransform = CGRect(x: 0, y: totalMenuHeight - wantedLayout.offset - wantedLayout.height, width: menuWidth, height: wantedLayout.height)
			}
			menuListView.contentView.transform = CGAffineTransform(translationX: 0, y: wantedLayout.contentOffset)
			menuListView.layoutIfNeeded()
		}

		// TODO: calculate anchorPoint.x
		let menuAttachmentPoint = menuAttachmentPointInSelfCoordinates
		var hostingFrame = CGRect.zero
		hostingFrame.size.width = menuWidth
		hostingFrame.origin.x = bounds.width * 0.5 - menuWidth * 0.5

		// finally lay out our hosting frame so that all the menus fit in it
		var anchorPoint = defaultAnchorPoint
		if isMenuDirectedDownwards == true {
			hostingFrame.size.height = totalMenuHeight
			hostingFrame.origin.y = max(min(menuAttachmentPoint.y, usableBounds.maxY - totalMenuHeight), usableBounds.minY)
		} else {
			hostingFrame.size.height = totalMenuHeight
			hostingFrame.origin.y = min(max(menuAttachmentPoint.y - totalMenuHeight, usableBounds.minY), usableBounds.maxY - totalMenuHeight)
		}

		if hostingFrame.height > 0 {
			// we set the anchor point so our appearance/disappearance animations go the `menuAttachmentPoint` visually
			anchorPoint.y = (menuAttachmentPoint.y - hostingFrame.origin.y) / hostingFrame.height
		}

		// and set it, ignoring any transforms
		hostingView.setFrameIgnoringTransform(hostingFrame, anchorPoint: anchorPoint)

		UIAccessibility.post(notification: .layoutChanged, argument: nil)
	}


	/// Updates the transform and alpha for a (sub)menu
	private func updateMenuTransformsAndOpacity() {
		// we have 3 cases

		var visibleMenuIndex = 0
		for menuListView in menuListViews.reversed() {
			if menuListView.isFullyMinimized == true {
				// fully minimized, hide everything
				menuListView.alpha = 0
				menuListView.shadowView.alpha = 0
				menuListView.isUserInteractionEnabled = false
			} else {
				menuListView.isUserInteractionEnabled = (visibleMenuIndex == 0)
				menuListView.alpha = 1


				if menuListView.isSubMenuOpen == false {
					menuListView.shadowView.alpha = 0
					menuListView.contentView.alpha = 1
					menuListView.transform = .identity
				} else {
					let scale = pow(CGFloat(0.97), CGFloat(visibleMenuIndex))
					menuListView.transform = CGAffineTransform(scaleX: scale, y: scale)
					menuListView.shadowView.alpha = (visibleMenuIndex == 0 ? 0.24 : 0.12)
					menuListView.contentView.alpha = (visibleMenuIndex == 0 ? 1 : 0.5)

					visibleMenuIndex += 1
				}
			}
		}
	}

	// MARK: Adding Menus
	/// Called when a menu item updated itself: do a layout pass because
	/// the size of the menu might have changed.
	private func handleUpdate(animated: Bool) {
		setNeedsLayout()
		if animated == true {
			// we use an ordinary, non-springy animtion
			UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction) {
				self.updateMenuViews()
				self.updateHighlightedMenuItemIfNeeded()
			}
		} else {
			self.updateHighlightedMenuItemIfNeeded()
		}
	}

	/// This adds a `MenuListView` to the `hostingView` and animates it appearance.
	/// If it's for the main menu `subMenu` is nil, otherwise it's set.
	private func addMenu(_ menu: Menu, animated: Bool) {
		// if something has the keyboard up in the current menu, dismiss it,
		// since we'll be showing another (sub)menu on top of it
		currentMenuListView?.endEditing(true)
		currentMenuListView?.stopScrolling()

		let isMainMenu = (currentMenuListView == nil)

		// create our new MenuListView that'll host the menu
		let menuListView = MenuListView()

		// we want to detect scrolls in the menuListView, so that we
		// can stop our highlighting if needed
		registerScrollView(menuListView.headerElementsListView.tableView)
		registerScrollView(menuListView.mainElementsListView.tableView)

		// set up the menu items and configuration
		menuListView.shouldInvertElementOrder = shouldInvertElementOrder
		menuListView.parentMenuListView = currentMenuListView
		menuListView.menuView = self
		menuListView.menu = menu
		menuListView.updateCallback = { [weak self] animated in self?.handleUpdate(animated: animated) }
		menuListViews.append(menuListView)

		// add it to our hosting view and do an initial layout pass, so we know the eventual
		// size of the menu
		hostingView.addSubview(menuListView)

		// then show the menu in minized form and do another layout pass
		// so that it's displayed small when the animation starts
		menuListView.isFullyMinimized = isMainMenu
		menuListView.isSubMenuOpen = isMainMenu
		updateMenuViews()

		if isMainMenu == true {
			// when we are presenting for the firsr time, we scale the whole menu
			// down
			hostingView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
		}

		// animate in our new menu by setting it to not be minimized anymore:
		// it'll have it's full size after the animation

		menuListView.isFullyMinimized = false
		animateIfNeeded(animated: animated, animations: { [self] in
			menuListView.isSubMenuOpen = true
			self.updateMenuViews()

			if isMainMenu == true {
				hostingView.transform = .identity
			}
		}, completion: { [weak self] in
			// new (sub)menu might have opened while we are highlighting,
			// update any possible highlighting now taking the new sub(menu)
			// into accout
			self?.updateHighlightedMenuItemIfNeeded()
		})
	}

	/// this determines the direction and alignment of our menu: we do this once at presentation, so that it doesn't change around.
	private func determineDirectionAndAlignment() {
		let rect = sourceRect ?? sourceView?.bounds ?? bounds
		isMenuDirectedDownwards = menuAttachmentPoint.y >= rect.midY

		if abs(menuAttachmentPoint.x - bounds.width * 0.5) < 20 {
			horizontalAlignment = .center
		} else {
			horizontalAlignment = menuAttachmentPoint.x < bounds.width ? .leading : .trailing
		}
	}


	/// Utility function to animate stuff conditionally. Does a spring animation.
	private func animateIfNeeded(animated: Bool, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
		if animated == true {
			// we use a nice bouncy spring animation
			let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: animations)
			animator.isManualHitTestingEnabled = true
			animator.isUserInteractionEnabled = true
			animator.addCompletion { _ in
				completion?()
			}
			animator.startAnimation()
		} else {
			animations()
			completion?()
		}
	}

	// MARK: Notifications
	@objc private func keyboardFrameWillChange(_ notification: Notification) {
		let newKeyboardScreenFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
		guard newKeyboardScreenFrame != keyboardScreenFrame else { return }
		keyboardScreenFrame = newKeyboardScreenFrame

		// the keyboard frame changed, animate our layout alongside it
		let animationCurve = UIView.AnimationCurve(rawValue: (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? 0) ?? .easeInOut
		let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
		let animationCurveOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
		UIView.animate(withDuration: animationDuration, delay: 0, options: [animationCurveOptions, .allowUserInteraction], animations: {
			self.setNeedsLayout()
			self.layoutIfNeeded()
		})
	}

	// MARK: - UIView
	override func layoutSubviews() {
		super.layoutSubviews()

		// update the maximum height for each (sub)menu. See the discussion in `maximumHeight`
		menuListViews.forEach { $0.maximumHeight = bounds.height }

		// and layout our list views.
		updateMenuViews()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(hostingView)

		// we recognize touches using a long press gesture recognizer with no delay
		highlightingGestureRecognizer.minimumPressDuration = 0
		highlightingGestureRecognizer.delegate = self
		addGestureRecognizer(highlightingGestureRecognizer)

		// we want to avoid the keyboard, so keep track of that
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

		accessibilityViewIsModal = true
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		dismiss(animated: true)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setNeedsLayout()
		layoutIfNeeded()
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if window == nil {
			stopTransferringLongPressGestureRecognizer()
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
}

extension MenuView: UIGestureRecognizerDelegate {
	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer == highlightingGestureRecognizer
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
		// if the user touches down on a control inside of our menu, that goes first
		return (event.allTouches?.first?.view is UIControl) == false
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		// we want to recognize touches together with the scrolling gesture recognizers from the top most menu's tableviews,
		// so that we can let the user potentially scroll/highlight at the same time, until we make a decision what the user
		// is doing and stop the other operation.
		return (otherGestureRecognizer.view as? UIScrollView)?.registrationIdentifier == identifier
	}
}

internal extension UIGestureRecognizer {
	func stopRecognizing() {
		// this is a small trick: if we want to stop a `UIGestureRecognizer` from
		// recognizing more touches, we toggle it to off-and-on again.
		isEnabled.toggle()
		isEnabled.toggle()
	}
}

fileprivate extension UIScrollView {
	static var registrationIdentifierKey = 0
	var registrationIdentifier: String? {
		get { objc_getAssociatedObject(self, &Self.registrationIdentifierKey) as? String }
		set { objc_setAssociatedObject(self, &Self.registrationIdentifierKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC) }
	}
}
