//
//  ActionInlineCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience

class ActionInlineCell: BaseInlineCell {
	let iconView = UIImageView(image: nil, contentMode: .scaleAspectFit)
	let titleLabel = UILabel(font: .preferredFont(forTextStyle: .footnote), color: .label, alignment: .center, numberOfLines: 2).disallowVerticalShrinking()

	func update(_ item: Action, animated: Bool) {
		iconView.image = item.image
		iconView.isHidden = (iconView.image == nil)

		titleLabel.text = item.title
		titleLabel.isHidden = ((item.title?.isEmpty ?? true) == true || size == .small)

		let contentColor: UIColor
		if item.isEnabled == false || item.isSelected == false {
			contentColor = item.mainContentColor
		} else {
			contentColor = tintColor
		}
		iconView.tintColor = contentColor
		titleLabel.textColor = contentColor

		accessibilityTraits.insert(.button)
		accessibilityTraits.toggle(.selected, on: item.isSelected)
		accessibilityTraits.toggle(.notEnabled, on: item.isEnabled == false)
	}

	func update(_ item: SubMenuElement, animated: Bool) {
		iconView.image = item.image
		iconView.isHidden = (iconView.image == nil)

		titleLabel.text = item.title
		titleLabel.isHidden = ((item.title?.isEmpty ?? true) == true || size == .small)

		let contentColor = item.mainContentColor
		iconView.tintColor = contentColor
		titleLabel.textColor = contentColor

		accessibilityTraits.insert(.button)
		accessibilityTraits.remove(.selected)
		accessibilityTraits.toggle(.notEnabled, on: item.isEnabled == false)
	}

	// MARK: - BaseInlineCell
	override var size: Menu.ElementSize {
		didSet {
			titleLabel.isHidden = (size == .small)
		}
	}

	override var labelForAccessibility: String? {
		return titleLabel.accessibilityLabel ?? iconView.image?.accessibilityLabel
	}

	override func update(animated: Bool) {
		if let element = element as? Action {
			update(element, animated: animated)
		} else if let element = element as? SubMenuElement {
			update(element, animated: animated)
		}
	}

	// MARK: - UIView
	override init(frame: CGRect) {
		super.init(frame: frame)

		iconView.tintColor = .label
		iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote)
		iconView.tintAdjustmentMode = .normal

		addSubview(
			.verticallyStacked(
				iconView,
				titleLabel,
				alignment: .center,
				spacing: 4
			).verticallyCentered(),
			filling: .superview,
			insets: .all(10)
		)
	}
}
