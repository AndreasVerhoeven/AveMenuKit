//
//  Buttons.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

internal class InlineGroup: MenuElement {
	open var elements: [MenuElement] {
		didSet {
			setNeedsUpdate()
		}
	}

	open var size: Menu.ElementSize = .medium {
		didSet {
			guard size != oldValue else { return }
			setNeedsUpdate()
		}
	}

	public init(size: Menu.ElementSize = .medium, elements: [MenuElement]) {
		self.size = size
		self.elements = elements
		super.init()
	}

	// MARK: - MenuElement
	override internal var isLeaf: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { InlineGroupCell.self }
}
