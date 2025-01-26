//
//  Menu.swift
//  Menu
//
//  Created by Andreas Verhoeven on 19/01/2025.
//

import UIKit

open class Menu: MenuElement, MenuStandardContent {
	public enum ElementSize {
		case small	/// 3 items in a row
		case medium /// 5 items in a row
		case large /// full width rows
		case automatic /// the menu figures it out
	}

	/// The order of the elements in a menu
	public enum ElementOrder {
		case automatic /// Determine the order automatically
		case priority /// The first item is closest to the source of presentation
		case fixed /// The order is always the same: the first item is on top of the menu
	}

	/// how we add separators to inline menus
	public enum MenuSeparatorStyle {
		case automatic
		case none
	}

	/// the way elements with `isSelected` set to `true` are shown
	/// in a palette.
	public enum PaletteSelectionStyle {
		case tint
		case openCircle
		case closedCircle
		case openRectangle
		case closeRectangle
	}

	/// the children of this menu - if this is an inline menu  or main menu they are
	/// shown inline in their parent menu, otherwise they are shown when this
	/// menu is opened.
	open var children = [MenuElement]() {
		didSet {
			setNeedsUpdate()
		}
	}

	/// Header elements are shown pinned on top of the children elements in a menu,
	/// if possible. Be careful not to add too many headers, as it might make the menu overflow.
	///
	/// For inline menus, the headers are shown inline as well, not pinned to top.
	open var headers = [MenuElement]() {
		didSet {
			setNeedsUpdate()
		}
	}

	/// How the elements in this menu should be shown: `small` and `medium`
	/// show the elements in an inline group that resembles buttons.
	/// `small` can show up to 3 elements, `medium` up to 5. Any extra elements
	/// are shown in a `regular` style.
	/// inline menus are shown separately in a regular style as well.
	open var preferredElementSize = ElementSize.automatic {
		didSet {
			guard preferredElementSize != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// If true, this menus contents will be shown inline in its parent, if false, it will open
	/// up on top of its parent.
	open var displaysInline = false {
		didSet {
			guard displaysInline != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// If true, the elements of this menu will be shown as a scrolling palette - if possible.
	open var displaysAsPalette = false {
		didSet {
			guard displaysAsPalette != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// Determines how elements that have `isSelected = true` are shown in the palette.
	open var paletteSelectionStyle = PaletteSelectionStyle.tint {
		didSet {
			guard paletteSelectionStyle != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// Determines if there are separators between `inline` submenus.
	open var betweenMenusSeparatorStyle = MenuSeparatorStyle.automatic {
		didSet {
			guard betweenMenusSeparatorStyle != oldValue else { return }
			guard displaysInline == true else { return }
			setNeedsUpdate()
		}
	}

	/// If true, when the menu is dismissed by our immediate children will show only dismiss
	/// the currently open submenu, instead of the whole menu - unless there are no submenus open.
	///
	/// This can be used to make a submenu where the user select an item, which then closes the submenu.
	open var onlyDismissesSubMenu = false

	// MARK: MenuStandardContentLeaf

	/// The optional title for this menu
	open var title: String? {
		didSet {
			guard title != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// The optional subtitle for this menu
	open var subtitle: String? {
		didSet {
			guard subtitle != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// The optional image for this menu
	open var image: UIImage? {
		didSet {
			guard image != oldValue else { return }
			setNeedsUpdate()
		}
	}

	// MARK: MenuLeaf
	/// If false, this submenu cannot be opened by tapping on its item.
	open var isEnabled = true {
		didSet {
			guard isEnabled != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// If true, this item should render to signal it's a destructive operation
	open var isDestructive = false {
		didSet {
			guard isDestructive != oldValue else { return }
			setNeedsUpdate()
		}
	}

	init(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil, isEnabled: Bool = true, isDestructive: Bool = false, preferredElementSize: Menu.ElementSize = ElementSize.automatic, displaysInline: Bool = false, displaysAsPalette: Bool = false, betweenMenusSeparatorStyle: MenuSeparatorStyle = .automatic, onlyDismissesSubMenu: Bool = false, children: [MenuElement], headers: [MenuElement] = []) {
		self.preferredElementSize = preferredElementSize
		self.displaysInline = displaysInline
		self.displaysAsPalette = displaysAsPalette 
		self.betweenMenusSeparatorStyle = betweenMenusSeparatorStyle
		self.onlyDismissesSubMenu = onlyDismissesSubMenu
		self.title = title
		self.subtitle = subtitle
		self.image = image
		self.isEnabled = isEnabled
		self.isDestructive = isDestructive
		self.children = children
		self.headers = headers
	}

	// MARK: - Internal
	internal var idForSubMenuElement: ID { "Element for submenu \(id)" }
	internal var idForSubMenuHeaderElement: ID { "Header for submenu \(id)" }

	internal weak var currentSubMenuHeaderElement: MenuElement?

	internal func cleanupAfterMenuDisplay() {
		subElements.removeAll()
	}

	internal func subElement<ElementType: MenuElement>(for subId: ID, creation: () -> ElementType) -> ElementType {
		if let cached = subElements[subId] as? ElementType {
			return cached
		}

		let element = creation().changingId(to: subId)
		subElements[subId] = element
		return element
	}

	internal override func notifyDelegateOfNeedsUpdate() {
		super.notifyDelegateOfNeedsUpdate()
		currentSubMenuHeaderElement?.notifyDelegateOfNeedsUpdate()
	}

	// MARK: - MenuElement
	override internal var canBeHighlighted: Bool { true }
	override internal var canShowSeparator: Bool { true }
	override internal var wantsLeadingInset: Bool { true }
	override internal var canBeShownInInlineGroup: Bool { true }
	override internal var autoInvokeOnLongHighlighting: Bool { true }

	override func actualMenuElements(properties: MenuProperties) -> [MenuElement] {
		if displaysInline == true {
			let all = headers + children
			return leafs(from: all, hasMenuHeader: false, properties: properties)
		} else {
			return [subMenuElement()]
		}
	}

	// MARK: - Privates
	private var subElements = [ID: MenuElement]()
}

extension Menu {
	public func paletteSelectionStyle(_ style: Menu.PaletteSelectionStyle) -> Self {
		self.paletteSelectionStyle = style
		return self
	}
}
