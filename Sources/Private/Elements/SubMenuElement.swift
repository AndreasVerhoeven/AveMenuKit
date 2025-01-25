//
//  SubMenuElement.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

internal class SubMenuElement: MenuElement, StateHaveableMenuLeaf {
	weak var menu: Menu?

	init(menu: Menu) {
		self.menu = menu
		super.init()
		self.id = menu.idForSubMenuElement
	}

	var title: String? { menu?.title }
	var subtitle: String? { menu?.subtitle }
	var image: UIImage? { menu?.image }
	var isEnabled: Bool { menu?.isEnabled ?? true }
	var isDestructive: Bool { menu?.isDestructive ?? true }

	// MARK: - Internal
	internal var smallContentColor: UIColor {
		if isEnabled == false {
			return .tertiaryLabel
		} else if isDestructive == true {
			return .systemRed
		} else {
			return .secondaryLabel
		}
	}

	// MARK: - MenuElement
	override var isHidden: Bool {
		get { menu?.isHidden ?? false }
		set {}
	}

	override internal var canBeHighlighted: Bool { isEnabled }
	override internal var canShowSeparator: Bool { true }
	override internal var wantsLeadingInset: Bool { true }
	override internal var autoInvokeOnLongHighlighting: Bool { true }
	override internal var keepsMenuPresentedOnPerform: Bool { true }

	override func perform() {
		guard let menu else { return }
		delegate?.toggleSubMenu(menu)
	}

	override internal var isLeaf: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuSubMenuCell.self }
}
