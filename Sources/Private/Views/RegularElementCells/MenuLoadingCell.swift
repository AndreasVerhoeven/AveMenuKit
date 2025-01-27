//
//  LoadingCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience

class MenuLoadingCell: MenuContentHostingCell {
	let titleLabel = UILabel(textStyle: .body, color: .secondaryLabel, numberOfLines: 2)
	let spinner = UIActivityIndicatorView(style: .medium)

	// MARK: ContentHostingCell
	override var trailingAccessoryView: UIView? {
		return spinner
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		titleLabel.text = NSLocalizedString("CONTEXT_MENU_LOADING", tableName: "Localizable", bundle: Bundle(for: UIApplication.classForCoder()), comment: "")

		menuContentView.addSubview(titleLabel, filling: .superview)
		spinner.startAnimating()

		accessibilityTraits.insert(.button)
		accessibilityTraits.insert(.notEnabled)
		accessibilityLabel = titleLabel.text
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		spinner.startAnimating()
	}

	// MARK: - UIView
	override func didMoveToWindow() {
		super.didMoveToWindow()
		spinner.startAnimating()
	}
	}
