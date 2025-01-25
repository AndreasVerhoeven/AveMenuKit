//
//  Palette.swift
//  Menu
//
//  Created by Andreas Verhoeven on 21/01/2025.
//

import UIKit

class InlinePalette: MenuElement {
	var elements: [MenuElement] {
		didSet {
			setNeedsUpdate()
		}
	}

	var selectionStyle = Menu.PaletteSelectionStyle.tint {
		didSet {
			guard selectionStyle != oldValue else { return }
			setNeedsUpdate()
		}
	}

	init(selectionStyle: Menu.PaletteSelectionStyle = .tint, elements: [MenuElement]) {
		self.selectionStyle = selectionStyle
		self.elements = elements
		super.init()
	}

	// MARK: - MenuElement
	override internal var isLeaf: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { InlinePaletteCell.self }
}
