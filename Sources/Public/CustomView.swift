//
//  CustomView.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// A simple view that can take up the full width of the menu. The element cannot be selected
/// by the user.
open class CustomView: MenuElement, NonSelectableMenuLeaf {
	/// the view to show
	open var view: ReusableViewConfiguration? {
		didSet {
			setNeedsUpdate()
		}
	}

	public init(view: ReusableViewConfiguration?) {
		self.view = view
		super.init()
	}

	public convenience init(viewProvider: @escaping () -> UIView) {
		self.init(view: .viewProvider(viewProvider))
	}

	public convenience init(view: UIView) {
		self.init(view: .view(view))
	}

	// MARK: - MenuElement
	override internal var canBeHighlighted: Bool { false }
	override internal var canBeShownInInlineGroup: Bool { false }

	override internal var isLeaf: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuCustomViewCell.self }
}
