//
//  MenuSubMenuHeaderCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 22/01/2025.
//

import UIKit

extension UIFont.TextStyle {
	static var emphasizedBody = Self(rawValue: "UICTFontTextStyleEmphasizedBody")
}

class MenuSubMenuHeaderCell: MenuSubMenuCell {
	let boldTitleLabel = UILabel(textStyle: .emphasizedBody, color: .label, numberOfLines: 2)
	let boldIconImageView = UIImageView(image: nil, contentMode: .scaleAspectFit)

	let obscuringView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))

	// MARK: - MenuSubMenuCell
	override func updateIconImageViewVisibility() {
		super.updateIconImageViewVisibility()
		boldIconImageView.isHidden = iconImageView.isHidden
	}

	// MARK: - MenuBaseCell
	override func update(animated: Bool) {
		super.update(animated: animated)

		obscuringView.presentationIdentifier = (element as? SubMenuHeaderElement)?.parentPresentationIdentifier

		boldIconImageView.tintColor = iconImageView.tintColor

		let hasNewTitle = (boldTitleLabel.text != titleLabel.text)
		boldTitleLabel.text = titleLabel.text
		boldTitleLabel.textColor = titleLabel.textColor
		boldIconImageView.image = iconImageView.image

		boldTitleLabel.isAccessibilityElement = false
		boldIconImageView.isAccessibilityElement = false

		if hasNewTitle {
			UIView.performWithoutAnimation {
				setNeedsLayout()
				layoutIfNeeded()
			}
		}

		UIView.performAnimationsIfNeeded(animated: animated, duration: 0.3, options: [.beginFromCurrentState, .overrideInheritedOptions]) { [self] in
			let alpha = CGFloat(showsAsOpened == true ? 1 : 0)
			let reversedAlpha = CGFloat(showsAsOpened == true ? 0 : 1)
			boldTitleLabel.alpha = alpha
			obscuringView.alpha = reversedAlpha

			if (iconImageView.image?.isSymbolImage ?? false) == true {
				boldIconImageView.alpha = alpha
			} else {
				boldIconImageView.alpha = 0
			}

			// we pretend to scale from a regular font to a bold font:
			// we do this by overlaying a copy of the titleLabel, but with bold font:
			// we crossfade them and scale them towards what is visible
			let boldSize = boldTitleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
			let titleSize = titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
			let scale = boldSize.width / max(titleSize.width, 1)
			let boldScale = titleSize.width / max(boldSize.width, 1)

			if showsAsOpened == true {
				titleLabel.setTransform(CGAffineTransform(scaleX: scale, y: 1), around: .zero)
				boldTitleLabel.transform = .identity
			} else {
				titleLabel.transform = .identity
				boldTitleLabel.setTransform(CGAffineTransform(scaleX: boldScale, y: 1), around: .zero)
			}

			titleLabel.alpha = 1
			iconImageView.alpha = reversedAlpha

			chevronView.transform = showsAsOpened == true ? CGAffineTransform(rotationAngle: .pi * 0.5) : .identity
		}
	}

	override func updateLayout(animated: Bool) {
		super.updateLayout(animated: animated)

		boldIconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .emphasizedBody)
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		menuContentView.addSubview(boldTitleLabel, filling: .relative(titleLabel))
		contentView.addSubview(boldIconImageView, centeredIn: .relative(iconImageView))

		boldIconImageView.tintAdjustmentMode = .normal
		iconImageView.tintAdjustmentMode = .normal

		boldTitleLabel.alpha = 0
		boldIconImageView.alpha = 0

		obscuringView.alpha = 0
		highlightingView.superview?.addSubview(obscuringView, filling: .superview)
	}
}
