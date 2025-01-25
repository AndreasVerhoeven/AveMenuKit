//
//  CustomContentViewAction.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// This is the most elaborate custom view. It mimicks the layout of an `Action`: it shows a
/// checkmark when selected, the custom view is displayed where the title and subtitle are shown
/// on `Action` and you can provide a custom view for the `trailingAccessoryView`,
/// where in Action its image is shown.
///
/// You use this if you want to have an `Action`, but with different content: e.g. you need more
/// control over the title or more control over the image, or you want to use a different UIView instead
/// of an image.
open class CustomContentViewAction: MenuElement, SelectableMenuActionLeaf {
	/// the contentView to show - its position and width are determined for you.
	open var contentView: ReusableViewConfiguration? {
		didSet {
			setNeedsUpdate()
		}
	}

	/// If set, this will be shown trailing to the content view and will be configured to have a certain
	/// maximum size.
	open var trailingAccessoryView: ReusableViewConfiguration? {
		didSet {
			setNeedsUpdate()
		}
	}

	// MARK: MenuLeaf
	/// if true, this item can be selected - if false, it cannot.
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
	open var handler: ((CustomContentViewAction) -> Void)?

	public init(contentView: ReusableViewConfiguration? = nil, trailingAccessoryView: ReusableViewConfiguration? = nil, isEnabled: Bool = true, isDestructive: Bool = false, isSelected: Bool = false, keepsMenuPresented: Bool = false, handler: ( (CustomContentViewAction) -> Void)? = nil) {
		self.contentView = contentView
		self.trailingAccessoryView = trailingAccessoryView
		self.isEnabled = isEnabled
		self.isDestructive = isDestructive
		self.isSelected = isSelected
		self.keepsMenuPresented = keepsMenuPresented
		self.handler = handler
	}

	// MARK: - MenuElement
	open override func perform() {
		handler?(self)
	}
	
	override internal var canBeHighlighted: Bool { isEnabled }
	override internal var wantsLeadingInset: Bool { isSelected }
	override internal var canBeShownInInlineGroup: Bool { false }
	override internal var keepsMenuPresentedOnPerform: Bool { keepsMenuPresented }

	override internal var isLeaf: Bool { true }
	override var elementTableViewCellClass: MenuBaseCell.Type { MenuCustomContentViewCell.self }
}
