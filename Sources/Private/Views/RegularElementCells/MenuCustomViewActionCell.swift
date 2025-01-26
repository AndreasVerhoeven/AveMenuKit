//
//  MenuCustomViewActionCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 23/01/2025.
//

import UIKit
import AutoLayoutConvenience

class MenuCustomViewActionCell: MenuBaseCell {
	let customView = ReusableView(kind: .header)

	// MARK: - BaseCell
	override func update(animated: Bool) {
		guard let reusableViewCache else { return }
		guard let presentedMenuElement else { return }
		guard let element = element as? CustomViewAction else { return }

		contentView.isUserInteractionEnabled = false
		customView.apply(element.view, for: presentedMenuElement, cache: reusableViewCache, parentView: contentView)

		let metrics = MenuMetrics(with: traitCollection, menuHasLeadingAccessories: menuHasLeadingAccessories, contentColor: element.mainContentColor)
		customView.update(metrics: metrics, animated: animated)

		accessibilityTraits.insert(.button)
		accessibilityTraits.toggle(.notEnabled, on: element.isEnabled == false)
	}
}
