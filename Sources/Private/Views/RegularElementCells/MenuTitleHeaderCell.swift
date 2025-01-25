//
//  TitleCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience
import UIKitAnimations

class MenuTitleHeaderCell: MenuContentHostingCell {
	let titleLabel = UILabel(font: .preferredFont(forTextStyle: .caption1), color: .secondaryLabel, numberOfLines: 2)

	// MARK: - BaseCell
	override func update(animated: Bool) {
		guard let element = element as? TitleHeader else { return }
		titleLabel.setText(element.title, animated: animated)
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		menuContentView.addSubview(titleLabel, filling: .superview, insets: .vertical(-2))
	}
}
