//
//  TitleHeader.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// A header with a title that is normally shown on top of inline submenus that have
/// a title.
open class TitleHeader: MenuElement, NonSelectableMenuLeaf {
	/// the title to show
	open var title: String {
		didSet {
			guard title != oldValue else { return }
			setNeedsUpdate()
		}
	}

	public init(title: String) {
		self.title = title
		super.init()
	}

	// MARK: - MenuElement
	override internal var isLeaf: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuTitleHeaderCell.self }
}
