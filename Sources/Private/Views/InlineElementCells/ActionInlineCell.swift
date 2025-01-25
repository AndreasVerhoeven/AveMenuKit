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

		/*
		let contentColor = item.mainContentColor(isSmall: true)
		iconView.tintColor = contentColor
		titleLabel.textColor = contentColor
		*/
	}

	func update(_ item: SubMenuElement, animated: Bool) {
		iconView.image = item.image
		iconView.isHidden = (iconView.image == nil)

		titleLabel.text = item.title
		titleLabel.isHidden = ((item.title?.isEmpty ?? true) == true || size == .small)

		/*
		let contentColor = item.mainContentColor(isSmall: true)
		iconView.tintColor = contentColor
		titleLabel.textColor = contentColor
		*/
	}

	// MARK: - BaseInlineCell
	override var size: Menu.ElementSize {
		didSet {
			titleLabel.isHidden = (size == .small)
		}
	}

	override func update(animated: Bool) {
		if let item = menuItem as? Action {
			update(item, animated: animated)
		} else if let item = menuItem as? SubMenuElement {
			update(item, animated: animated)
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
