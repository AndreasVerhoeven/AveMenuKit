//
//  SubMenuHeaderElement.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

internal class SubMenuHeaderElement: SubMenuElement {
	init(menu: Menu, parentPresentationIdentifier: String? = nil) {
		super.init(menu: menu)
		self.id = menu.idForSubMenuHeaderElement
		self.parentPresentationIdentifier = parentPresentationIdentifier
		menu.currentSubMenuHeaderElement = self
	}

	var parentPresentationIdentifier: String?

	// MARK: - MenuElement
	override internal var isLeaf: Bool { true }
	override internal var canBeHighlighted: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuSubMenuHeaderCell.self }
}
