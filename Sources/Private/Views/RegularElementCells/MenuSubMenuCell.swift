//
//  SubMenuCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 13/01/2025.
//

import UIKit


class MenuSubMenuCell: MenuContentHostingCell {
	let titleLabel = UILabel(font: .preferredFont(forTextStyle: .body), color: .label, numberOfLines: 2)
	let subtitleLabel = UILabel(font: .preferredFont(forTextStyle: .subheadline), color: .secondaryLabel, numberOfLines: 2)
	let iconImageView = UIImageView(image: nil, contentMode: .scaleAspectFit)
	let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"), contentMode: .scaleAspectFit)

	public func updateIconImageViewVisibility() {
		iconImageView.isHidden = (iconImageView.image == nil || traitCollection.preferredContentSizeCategory.isAccessibilityCategory)
	}

	// MARK: - Privates

	// MARK: ContentBaseCell
	override var leadingAccessoryView: UIImageView? {
		return chevronView
	}

	override var trailingAccessoryView: UIImageView? {
		return iconImageView
	}

	// MARK: - BaseCell
	override func update(animated: Bool) {
		guard let element = element as? SubMenuElement else { return }
		let contentColor = element.mainContentColor

		titleLabel.setText(element.title, textColor: contentColor, animated: animated)
		subtitleLabel.setText(element.subtitle, animated: animated)
		subtitleLabel.isHidden = (element.subtitle == nil || element.subtitle == "")
		iconImageView.setImage(element.image, tintColor: contentColor, animated: animated)
		chevronView.tintColor = contentColor
		updateIconImageViewVisibility()
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		tintAdjustmentMode = .normal
		iconImageView.tintColor = .label
		chevronView.tintColor = .label

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

