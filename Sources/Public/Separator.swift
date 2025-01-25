//
//  Separator.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// Shows a separator that is normally shown between different inline submenus.
open class Separator: MenuElement, NonSelectableMenuLeaf {
	public override init() {
		super.init()
	}

	// MARK: - MenuElement
	override internal var canShowSeparator: Bool { false }
	override internal var isLeaf: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuSeparatorCell.self }
}
