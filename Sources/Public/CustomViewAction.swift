//
//  CustomViewAction.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// This is a custom view that the user can select. (As a consequence, the custom view itself cannot be interacted with.)
open class CustomViewAction: MenuElement, MenuActionLeaf {
	/// the view to show
	open var view: ReusableViewConfiguration? {
		didSet {
			setNeedsUpdate()
		}
	}

	// MARK: MenuLeaf
	/// If false, this item cannot be selected
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

	/// if true, tapping on this action will not dismiss the menu
	open var keepsMenuPresented = false

	/// will be called when the action is invoked
	open var handler: ((CustomViewAction) -> Void)?

	public init(view: ReusableViewConfiguration? = nil, isEnabled: Bool = true, isDestructive: Bool = false, keepsMenuPresented: Bool = false, handler: ((CustomViewAction) -> Void)? = nil) {
		self.view = view
		self.isEnabled = isEnabled
		self.isDestructive = isDestructive
		self.keepsMenuPresented = keepsMenuPresented
		self.handler = handler
	}

	public convenience init(viewProvider: @escaping () -> UIView) {
		self.init(view: .viewProvider(viewProvider))
	}

	public convenience init(view: UIView) {
		self.init(view: .view(view))
	}

	// MARK: - MenuElement
	open override func perform() {
		handler?(self)
	}

	override internal var canBeHighlighted: Bool { isEnabled }
	override internal var canBeShownInInlineGroup: Bool { false }
	override internal var keepsMenuPresentedOnPerform: Bool { keepsMenuPresented }

	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuCustomViewActionCell.self }
	override internal var isLeaf: Bool { true }
}
