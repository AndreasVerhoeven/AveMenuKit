//
//  SeparatorCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience

class MenuSeparatorCell: MenuBaseCell {
	let view = UIView()

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		view.backgroundColor = UIColor(dynamicProvider: { traitCollection in
			switch traitCollection.userInterfaceStyle {
				case .dark:
					return UIColor(white: 0, alpha: 0.16)

				case .light, .unspecified:
					fallthrough
				@unknown default:
					return UIColor(white: 0, alpha: 0.08)
			}
		})
		view.constrain(height: 8)
		contentView.addSubview(view, filling: .superview)

		isAccessibilityElement = false
	}
}
