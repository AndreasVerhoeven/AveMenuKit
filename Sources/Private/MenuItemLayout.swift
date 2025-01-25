//
//  MenuItemLayout.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit

class MenuItemLayout {
	enum Defaults {
		static let contentInset = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
		static let leadingAccessoryCenterXOffset = CGFloat(18)
		static let trailingAccessoryCenterXOffset = CGFloat(28)

		static let hasLeadingAccessoryContentLeadingInset = CGFloat(32)
		static let hasTrailingAccessoryContentTrailingInset = CGFloat(44)

		static let maximumIconWidth = CGFloat(24)
		static let maximumIconHeight = CGFloat(32)

		static let leadingAccessorySymbolScale = UIImage.SymbolScale.small
	}

	private(set) var contentInset = Defaults.contentInset
	private(set) var leadingAccessoryCenterXOffset = Defaults.leadingAccessoryCenterXOffset
	private(set) var trailingAccessoryCenterXOffset = Defaults.trailingAccessoryCenterXOffset

	private(set) var hasLeadingAccessoryContentLeadingInset = Defaults.hasLeadingAccessoryContentLeadingInset
	private(set) var hasTrailingAccessoryContentTrailingInset = Defaults.hasTrailingAccessoryContentTrailingInset

	private(set) var maximumIconWidth = Defaults.maximumIconWidth
	private(set) var maximumIconHeight = Defaults.maximumIconHeight

	private(set) var leadingAccessorySymbolScale = Defaults.leadingAccessorySymbolScale

	private(set) var isInitial = true
	private(set) var hasLeadingAccessory = false
	private(set) var hasTrailingAccessory = false
	private(set) var contentSizeCategory = UIContentSizeCategory.large

	func reset() {
		isInitial = true
	}

	func needsUpdateFor(hasLeadingAccessory: Bool, hasTrailingAccessory: Bool, traitCollection: UITraitCollection) -> Bool {
		return (isInitial == true
				|| contentSizeCategory != traitCollection.preferredContentSizeCategory
				|| self.hasLeadingAccessory != hasLeadingAccessory
				|| self.hasTrailingAccessory != hasTrailingAccessory)
	}

	func updateFor(hasLeadingAccessory: Bool, hasTrailingAccessory: Bool, traitCollection: UITraitCollection) -> Bool {
		guard needsUpdateFor(hasLeadingAccessory: hasLeadingAccessory, hasTrailingAccessory: hasTrailingAccessory, traitCollection: traitCollection) else { return false }

		isInitial = false
		self.hasLeadingAccessory = hasLeadingAccessory
		self.hasTrailingAccessory = hasTrailingAccessory
		contentSizeCategory = traitCollection.preferredContentSizeCategory
		
		let metrics = UIFontMetrics(forTextStyle: .body)
		maximumIconWidth = metrics.scaledValue(for: Defaults.maximumIconWidth)
		maximumIconHeight = metrics.scaledValue(for: Defaults.maximumIconHeight)

		contentInset = Defaults.contentInset
		if hasLeadingAccessory == true {
			contentInset.leading = Defaults.hasLeadingAccessoryContentLeadingInset

			if contentSizeCategory.isAccessibilityCategory == true {
				contentInset.leading = metrics.scaledValue(for: contentInset.leading)
			}
		}

		if hasTrailingAccessory == true {
			contentInset.trailing = maximumIconWidth * 0.5// Defaults.hasTrailingAccessoryContentTrailingInset

			//if contentSizeCategory.isAccessibilityCategory == true {
			//	contentInset.trailing = metrics.scaledValue(for: contentInset.trailing)
			//}
		}



		if contentSizeCategory.isAccessibilityCategory == true {
			contentInset.top = metrics.scaledValue(for: contentInset.top)
			contentInset.bottom = metrics.scaledValue(for: contentInset.bottom)
			leadingAccessoryCenterXOffset = metrics.scaledValue(for: Defaults.leadingAccessoryCenterXOffset)
			trailingAccessoryCenterXOffset = metrics.scaledValue(for: Defaults.trailingAccessoryCenterXOffset)
			leadingAccessorySymbolScale = .default
		} else {
			leadingAccessorySymbolScale = Defaults.leadingAccessorySymbolScale
		}

		return true
	}
}
