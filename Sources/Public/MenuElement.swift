//
//  MenuElement.swift
//  Menu
//
//  Created by Andreas Verhoeven on 19/01/2025.
//

import UIKit

/// Base class for any MenuElement; you should not subclass this directly
/// but subclass `Group` and provide other elements
open class MenuElement: Identifiable {
	/// internal unique identifier - will be unique in a menu and its submenus
	public internal(set) var id = UUID().uuidString

	/// If true, the element (and its children) will not show up in the menu
	open var isHidden = false {
		didSet {
			guard isHidden != oldValue else { return }
			notifyDelegateOfNeedsUpdate()
		}
	}

	/// If you subclass another `MenuElement`, you should call this if
	/// something requires the menu to update.
	open func setNeedsUpdate() {
		guard isHidden == false else { return }
		notifyDelegateOfNeedsUpdate()
	}

	/// This is called when the `MenuElement` is invoked by
	/// tapping on it.
	open func perform() {}

	// MARK: - Module Internal
	internal var ignoreUpdateCounter = 0

	internal func ignoringUpdates(action: () -> Void) {
		ignoreUpdateCounter += 1
		defer { ignoreUpdateCounter -= 1 }
		action()
	}

	internal init() {

	}

	// MARK: Configuration Flags
	internal var canBeHighlighted: Bool { false }
	internal var canShowSeparator: Bool { true }
	internal var wantsLeadingInset: Bool { false }
	internal var canBeShownInInlineGroup: Bool { true }
	internal var autoInvokeOnLongHighlighting: Bool { false }
	internal var keepsMenuPresentedOnPerform: Bool { false }

	// MARK: Delegate
	internal weak var delegate: MenuElementDelegate?

	// MARK: Getting Leaf Elements
	internal var isLeaf: Bool { false }

	internal func actualMenuElements(properties: MenuProperties) -> [MenuElement] { [] }

	// MARK: Preparing to show
	internal func prepareForDisplayInMenu(properties: MenuProperties) {}
	internal func cleanupAfterDisplay() {}

	// MARK: Rendering
	internal var elementTableViewCellClass: MenuBaseCell.Type {
		fatalError("Subclass \(type(of: self)) of MenuElement is used as a leaf class and doesn't implement elementTableViewCellClass")
	}

	internal func notifyDelegateOfNeedsUpdate() {
		guard ignoreUpdateCounter <= 0 else { return }
		delegate?.setNeedsUpdate()
	}
}
