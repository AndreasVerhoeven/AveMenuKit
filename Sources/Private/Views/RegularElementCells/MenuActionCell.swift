//
//  ActionCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import UIKitAnimations

class MenuActionCell: MenuContentHostingCell {
	let titleLabel = UILabel(font: .preferredFont(forTextStyle: .body), color: .label, numberOfLines: 2)
	let subtitleLabel = UILabel(font: .preferredFont(forTextStyle: .subheadline), color: .secondaryLabel, numberOfLines: 2)
	let iconImageView = UIImageView(image: nil, contentMode: .scaleAspectFit)
	let checkmarkView = UIImageView(image: UIImage(systemName: "checkmark"), contentMode: .scaleAspectFit)

	// MARK: - Privates
	private func updateIconImageViewVisibility() {
		iconImageView.isHidden = (iconImageView.image == nil || traitCollection.preferredContentSizeCategory.isAccessibilityCategory)
	}

	// MARK: ContentBaseCell
	override var leadingAccessoryView: UIImageView? {
		return checkmarkView
	}

	override var trailingAccessoryView: UIImageView? {
		return iconImageView
	}

	// MARK: - BaseCell
	override func update(animated: Bool) {
		guard let element = element as? Action else { return }

		let contentColor = element.mainContentColor

		titleLabel.setText(element.title, textColor: contentColor, animated: animated)
		subtitleLabel.setText(element.subtitle, animated: animated)
		subtitleLabel.isHidden = (element.subtitle == nil || element.subtitle == "")
		iconImageView.setImage(element.imageToUse, tintColor: contentColor, animated: animated)
		updateIconImageViewVisibility()

		checkmarkView.tintColor = contentColor
		checkmarkView.isHidden = (element.isSelected == false)

		accessibilityTraits.insert(.button)
		accessibilityTraits.toggle(.selected, on: element.isSelected)
		accessibilityTraits.toggle(.notEnabled, on: element.isEnabled == false)
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		tintAdjustmentMode = .normal
		iconImageView.tintColor = .label
		checkmarkView.tintColor = .label

		updateIconImageViewVisibility()
		menuContentView.addSubview(
			.verticallyStacked(
				titleLabel,
				subtitleLabel
			),
			filling: .superview
		)
	}

	// MARK: - UIView
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		updateIconImageViewVisibility()
		super.traitCollectionDidChange(previousTraitCollection)
	}
}
