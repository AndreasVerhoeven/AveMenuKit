//
//  CustomHeaderViewCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 16/01/2025.
//

import UIKit
import AutoLayoutConvenience

class MenuCustomViewCell: MenuBaseCell {
	let customView = ReusableView(kind: .header)

	// MARK: - BaseCell
	override func update(animated: Bool) {
		guard let reusableViewCache else { return }
		guard let presentedMenuElement else { return }
		guard let element = element as? CustomView else { return }

		customView.apply(element.view, for: presentedMenuElement, cache: reusableViewCache, parentView: contentView)

		let metrics = MenuMetrics(with: traitCollection, menuHasLeadingAccessories: menuHasLeadingAccessories)
		customView.update(metrics: metrics, animated: animated)
	}
}
