//
//  MenuMetrics+Internal.swift
//  Demo
//
//  Created by Andreas Verhoeven on 25/01/2025.
//

import UIKit

extension MenuMetrics {
	enum Defaults {
		static let contentInset = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
		static let leadingAccessoryCenterXOffset = CGFloat(18)
		static let trailingAccessoryCenterXOffset = CGFloat(28)

		static let leadingContentInsetOverrideWhenHavingAccessory = CGFloat(32)
		static let offsetBetweenTrailingContentAndCenterOfTrailingAccessory = CGFloat(0)

		static let maximumIconSize = CGSize(width: 24, height: 32)
		static let leadingAccessorySymbolScale = UIImage.SymbolScale.small
		static let canShowTrailingAccessory = true
		static let menuHasLeadingAccessories = false
	}

	init(with traitCollection: UITraitCollection, menuHasLeadingAccessories: Bool, contentColor: UIColor? = nil) {
		contentInsets = Defaults.contentInset
		leadingAccessoryCenterXOffset = Defaults.leadingAccessoryCenterXOffset
		trailingAccessoryCenterXOffset = Defaults.trailingAccessoryCenterXOffset
		maximumIconSize = Defaults.maximumIconSize
		leadingAccessorySymbolScale = Defaults.leadingAccessorySymbolScale
		canShowTrailingAccessory = Defaults.canShowTrailingAccessory
		leadingContentInsetOverrideWhenHavingAccessory = Defaults.leadingContentInsetOverrideWhenHavingAccessory
		self.menuHasLeadingAccessories = menuHasLeadingAccessories
		self.contentColor = contentColor ?? self.contentColor

		let metrics = UIFontMetrics(forTextStyle: .body)
		maximumIconSize = CGSize(
			width: metrics.scaledValue(for: maximumIconSize.width),
			height: metrics.scaledValue(for: maximumIconSize.height)
		)

		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory == true {
			contentInsets.top = metrics.scaledValue(for: contentInsets.top)
			contentInsets.bottom = metrics.scaledValue(for: contentInsets.bottom)
			leadingAccessoryCenterXOffset = metrics.scaledValue(for: leadingAccessoryCenterXOffset)
			trailingAccessoryCenterXOffset = metrics.scaledValue(for: trailingAccessoryCenterXOffset)
			leadingAccessorySymbolScale = .default

			leadingContentInsetOverrideWhenHavingAccessory = metrics.scaledValue(for: leadingContentInsetOverrideWhenHavingAccessory)
		}

		if menuHasLeadingAccessories {
			contentInsets.leading = leadingContentInsetOverrideWhenHavingAccessory
		}

		offsetBetweenTrailingContentAndCenterOfTrailingAccessory = maximumIconSize.width * 0.5
	}
}
