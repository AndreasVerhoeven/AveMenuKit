//
//  LoadingInlineCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit

class LoadingInlineCell: BaseInlineCell {
	let spinner = UIActivityIndicatorView(style: .medium)
	let titleLabel = UILabel(font: .preferredFont(forTextStyle: .footnote), color: .secondaryLabel, alignment: .center, numberOfLines: 2)

	// MARK: - BaseInlineCell
	override var size: Menu.ElementSize {
		didSet {
			titleLabel.isHidden = (size == .small)
		}
	}

	// MARK: - UIView
	override func didMoveToWindow() {
		super.didMoveToWindow()
		spinner.startAnimating()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		titleLabel.text = NSLocalizedString("CONTEXT_MENU_LOADING", tableName: "Localizable", bundle: Bundle(for: UIApplication.classForCoder()), comment: "")

		addSubview(
			.verticallyStacked(
				spinner,
				titleLabel
			).verticallyCentered(),
			filling: .superview,
			insets: .all(10)
		)
		spinner.startAnimating()
	}
}

