//
//  MenuMetrics.swift
//  Menu
//
//  Created by Andreas Verhoeven on 21/01/2025.
//

import UIKit

/// These are metrics you can use to lay out your custom views
/// You don't need to use the insets and offset metrics for `CustomContentViewAction`
/// views: the positioning and layout is done for you.
public struct MenuMetrics: Equatable {
	/// the preferred maximum number of lines for UILabels
	public internal(set) var maximumNumberOfLines = 2

	/// the preferred font for text
	public internal(set) var contentFont = UIFont.preferredFont(forTextStyle: .body)

	// MARK: Content
	/// The color the content should be rendered in - based on `isDestructive` and `isEnabled` flags if available
	public internal(set) var contentColor = UIColor.label

	/// how much we want to inset the content from the edges. Note that the leading edge might
	/// be insetted because of other elements having a leading accessory.
	///
	/// Note that the built-in `Action` layout pins itself to
	/// the `trailingAccessory`  using `offsetBetweenTrailingContentAndCenterOfTrailingAccessory`
	/// __when__ there is a trailing accessory.
	public internal(set) var contentInsets = NSDirectionalEdgeInsets.zero

	// MARK: Leading Accessory
	/// if true the menu has leading accessories
	public internal(set) var menuHasLeadingAccessories = false

	/// the leading accessory's center is offsetted by this much from the leading edge
	public internal(set) var leadingAccessoryCenterXOffset = CGFloat(0)

	/// the scale to use for the leading accessory
	public internal(set) var leadingAccessorySymbolScale = UIImage.SymbolScale.small

	/// the leading content inset that will be used when we have a leading accessory - this will already be
	public internal(set) var leadingContentInsetOverrideWhenHavingAccessory = CGFloat(0)

	// MARK: Trailing Accessory
	/// true if we can show the trailing accessory
	public internal(set) var canShowTrailingAccessory = false

	/// the trailing accessory's center is offsetted by this much from the leading edge
	public internal(set) var trailingAccessoryCenterXOffset = CGFloat(0)

	/// the maximum size of an icon
	public internal(set) var maximumIconSize = CGSize.zero

	/// the offset between the content trailing edge and the center of the trailing accessory if there is one
	/// See `effectiveInsetsBetweenLeadingEdgeAndTrailingAccessoryCenter` and
	/// `effectiveTrailingInsetInSuperview` and `effectiveInsetsInSuperview`
	public internal(set) var offsetBetweenTrailingContentAndCenterOfTrailingAccessory = CGFloat(0)

	/// Returns true if this metrics will result in an effective different layout than other metrics
	public func hasDifferentLayout(from other: MenuMetrics) -> Bool {
		return (
			contentInsets != other.contentInsets
			|| maximumIconSize != other.maximumIconSize
			|| offsetBetweenTrailingContentAndCenterOfTrailingAccessory != other.offsetBetweenTrailingContentAndCenterOfTrailingAccessory
			|| canShowTrailingAccessory != other.canShowTrailingAccessory
		)
	}

	/// The effective insets if you lay out your content between the leading edge of the superview and the trailing edge to the center of the
	/// trailing accessory.
	public var effectiveInsetsBetweenLeadingEdgeAndTrailingAccessoryCenter: NSDirectionalEdgeInsets {
		var insets = contentInsets
		insets.trailing = offsetBetweenTrailingContentAndCenterOfTrailingAccessory
		return insets
	}

	/// If you do not pin your content to the trailing accessory's center, this is the inset from the trailing edge superview
	public func effectiveTrailingInsetInSuperview(hasTrailingAccessory: Bool) -> CGFloat {
		return trailingAccessoryCenterXOffset + offsetBetweenTrailingContentAndCenterOfTrailingAccessory
	}

	/// If you do not pin your content to the trailing accessory's center, this is the inset in the superview
	public func effectiveInsetsInSuperview(hasTrailingAccessory: Bool) -> NSDirectionalEdgeInsets {
		var insets = contentInsets
		insets.trailing = effectiveTrailingInsetInSuperview(hasTrailingAccessory: hasTrailingAccessory)
		return insets

	}
}
