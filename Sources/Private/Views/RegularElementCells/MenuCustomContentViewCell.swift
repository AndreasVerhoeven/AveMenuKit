//
//  ContentRowCustomViewCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 16/01/2025.
//

import UIKit
import AutoLayoutConvenience
import UIKitAnimations

class MenuCustomContentViewCell: MenuContentHostingCell {
	let customContentReusableView = ReusableView(kind: .contentRow)
	let customTrailingAccessoryReusableView = ReusableView(kind: .trailingAccessory)

	let checkmarkView = UIImageView(image: UIImage(systemName: "checkmark"), contentMode: .scaleAspectFit)

	// MARK: - ContentHostingCell
	override var leadingAccessoryView: UIImageView? {
		return checkmarkView
	}
	override var trailingAccessoryView: UIView? {
		return customTrailingAccessoryReusableView.view
	}

	// MARK: - BaseCell
	override func update(animated: Bool) {
		guard let reusableViewCache else { return }
		guard let presentedMenuElement else { return }
		guard let element = element as? CustomContentViewAction else { return }

		customContentReusableView.apply(element.contentView, for: presentedMenuElement, cache: reusableViewCache, parentView: menuContentView)
		customTrailingAccessoryReusableView.apply(element.trailingAccessoryView, for: presentedMenuElement, cache: reusableViewCache)

		let metrics = MenuMetrics(with: traitCollection, menuHasLeadingAccessories: menuHasLeadingAccessories, contentColor: element.mainContentColor)
		customContentReusableView.update(metrics: metrics, animated: animated)
		customTrailingAccessoryReusableView.update(metrics: metrics, animated: animated)

		checkmarkView.tintColor = metrics.contentColor
		checkmarkView.isHidden = (element.isSelected == false)

		accessibilityTraits.insert(.button)
		accessibilityTraits.toggle(.selected, on: element.isSelected)
		accessibilityTraits.toggle(.notEnabled, on: element.isEnabled == false)
	}
}
