//
//  Action.swift
//  Menu
//
//  Created by Andreas Verhoeven on 19/01/2025.
//

import UIKit

open class Action: MenuElement, SelectableMenuActionLeaf, MenuStandardContentLeaf {
	// MARK: MenuStandardContentLeaf
	/// the title for this action
	open var title: String? {
		didSet {
			guard title != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// optional subtitle shown underneath the title
	open var subtitle: String? {
		didSet {
			guard subtitle != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// image to show
	open var image: UIImage? {
		didSet {
			guard image !== oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// if set and `isSelected = true`, this image will be shown for the action instead
	open var selectedImage: UIImage? {
		didSet {
			guard image !== oldValue else { return }
			setNeedsUpdate()
		}
	}

	// MARK: MenuLeaf
	/// If false, this action cannot be invoked by the user
	open var isEnabled = true {
		didSet {
			guard isEnabled != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// if true, this action will be shown as destructive, e.g. with red text.
	open var isDestructive = false {
		didSet {
			guard isDestructive != oldValue else { return }
			setNeedsUpdate()
		}
	}

	// MARK: SelectableMenuActionLeaf
	/// if true, a checkmark will be shown next to the action
	open var isSelected = false {
		didSet {
			guard isSelected != oldValue else { return }
			setNeedsUpdate()
		}
	}
	
	/// if true, tapping on this action will not dismiss the menu
	open var keepsMenuPresented = false

	/// will be called when the action is invoked
	open var handler: ((Action) -> Void)?

	public init(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil, isEnabled: Bool = true, isDestructive: Bool = false, isSelected: Bool = false, keepsMenuPresented: Bool = false, handler: ((Action) -> Void)? = nil) {
		self.title = title
		self.subtitle = subtitle
		self.image = image
		self.selectedImage = selectedImage
		self.isEnabled = isEnabled
		self.isDestructive = isDestructive
		self.isSelected = isSelected
		self.keepsMenuPresented = keepsMenuPresented
		self.handler = handler
	}

	// MARK: - Internal
	internal var imageToUse: UIImage? {
		if isSelected {
			return selectedImage ?? image
		} else {
			return image
		}
	}

	internal var smallContentColor: UIColor? {
		if isEnabled == false {
			return .tertiaryLabel
		} else if isDestructive == true {
			return .systemRed
		} else if isSelected == true {
			return nil
		} else {
			return .secondaryLabel
		}
	}

	// MARK: - MenuElement
	override internal var canBeHighlighted: Bool { isEnabled }
	override internal var wantsLeadingInset: Bool { isSelected }
	override internal var keepsMenuPresentedOnPerform: Bool { keepsMenuPresented }
	override internal var isLeaf: Bool { true }

	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuActionCell.self }

	open override func perform() {
		handler?(self)
	}
}

extension Action {
	public func handler(_ handler: @escaping () -> Void) -> Self {
		self.handler = { _ in handler() }
		return self
	}

	public func handler(_ handler: @escaping (Action) -> Void) -> Self {
		self.handler = handler
		return self
	}
}
