//
//  PaletteElementContentCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 23/01/2025.
//

import UIKit
import AutoLayoutConvenience
import AveCommonHelperViews

class PaletteElementContentCell: UICollectionViewCell {
	let contentHostingView = UIView()
	let titleLabel = UILabel(textStyle: .body, color: .secondaryLabel, numberOfLines: 1)
	let imageView = UIImageView(contentMode: .scaleAspectFit)
	let highlightingClipView = UIView()
	let highlightingView = UIView.menuHighlightingView()
	let selectionView = RoundRectView()

	var selectionStyle = Menu.PaletteSelectionStyle.tint

	private(set) var presentedElement: PresentedMenuElement?
	var element: MenuElement? { presentedElement?.element }
	var isSetupForImage = false
	var lastUsedContentSizeCategory: UIContentSizeCategory?

	func setPresentedElement(_ element: PresentedMenuElement, animated: Bool) {
		self.presentedElement = element
		update(animated: animated)
	}

	func update(animated: Bool) {
		var image: UIImage?
		var title: String?
		var contentColor: UIColor? = .secondaryLabel
		var isSelected = false

		if let action = element as? Action {
			isSelected = action.isSelected
			image = action.image
			title = action.title
			contentColor = action.smallContentColor ?? tintColor

			accessibilityTraits.insert(.button)
			accessibilityTraits.toggle(.selected, on: action.isSelected)
			accessibilityTraits.toggle(.notEnabled, on: action.isEnabled == false)

		} else if let subMenu = element as? SubMenuElement {
			image = subMenu.image
			title = subMenu.title
			contentColor = subMenu.smallContentColor

			accessibilityTraits.insert(.button)
			accessibilityTraits.remove(.selected)
			accessibilityTraits.toggle(.notEnabled, on: subMenu.isEnabled == false)
		}

		if let image {
			titleLabel.setText(nil, textColor: contentColor, animated: animated)
			imageView.setImage(image.withAlignmentRectInsets(.zero), tintColor: contentColor, animated: animated)
		} else {
			titleLabel.setText(title, textColor: contentColor, animated: animated)
			imageView.setImage(nil, tintColor: contentColor, animated: animated)
		}

		let shouldBeSetupForImage = (image != nil)
		let newContentSizeCategory = traitCollection.preferredContentSizeCategory
		let contentSizeCategoryChanged = (newContentSizeCategory != lastUsedContentSizeCategory)
		lastUsedContentSizeCategory = newContentSizeCategory

		if isSetupForImage != shouldBeSetupForImage || (shouldBeSetupForImage == true && contentSizeCategoryChanged) {
			isSetupForImage = shouldBeSetupForImage
			contentHostingView.replaceStoredConstraints {
				installConstraints()
			}
		}

		switch selectionStyle {
			case .tint:
				selectionView.isHidden = true

			case .openCircle, .openRectangle:
				selectionView.isHidden = false
				selectionView.backgroundColor = nil
				selectionView.cornerRadius = RoundRectView.alwaysVerticalCircleCorners
				selectionView.borderColor = tintColor
				selectionView.borderWidth = 2

			case .closedCircle, .closeRectangle:
				selectionView.isHidden = false
				selectionView.cornerRadius = 3
				selectionView.backgroundColor = tintColor
				selectionView.borderColor = tintColor
				selectionView.borderWidth = 2
		}

		selectionView.alpha = (isSelected == true ? 1 : 0)
		setNeedsLayout()
		layoutIfNeeded()
	}

	var showsAsHighlighted = false {
		didSet {
			guard showsAsHighlighted != oldValue else { return }
			highlightingClipView.alpha = (showsAsHighlighted == true ? 1 : 0)
		}
	}

	var labelForAccessibility: String? {
		if let action = element as? Action {
			return action.title ?? action.image?.accessibilityLabel
		} else if let subMenu = element as? SubMenuElement {
			return subMenu.title ?? subMenu.image?.accessibilityLabel
		} else {
			return nil
		}
	}


	// MARK: - Privates
	private func installConstraints() {
		contentHostingView.replaceStoredConstraints {
			if isSetupForImage == true {
				let minimalWidth = UIFontMetrics(forTextStyle: .body).scaledValue(for: 54) - 16
				UIView.batchConstraints {
					if let guide = imageView.value(forKey: "imageContentGuide") as? UILayoutGuide {
						contentHostingView.addSubview(selectionView, filling: .guide(guide), insets: .all(-4))
					} else {
						contentHostingView.addSubview(selectionView, filling: .relative(imageView), insets: .all(-4)).changePriority(.defaultHigh)
					}

					contentHostingView.addSubview(titleLabel, centeredIn: .superview)
					contentHostingView.addSubview(imageView, centeredIn: .superview)
					contentHostingView.constrain(width: minimalWidth)
				}
			} else {
				UIView.batchConstraints {
					contentHostingView.addSubview(selectionView, filling: .relative(titleLabel), insets: .all(-4)).changePriority(.defaultHigh)

					contentHostingView.addSubview(titleLabel, filling: .superview, insets: .horizontally(10, vertically: 8))
					contentHostingView.addSubview(imageView, centeredIn: .superview)
				}
			}
		}
	}

	// MARK: - UIView
	override init(frame: CGRect) {
		super.init(frame: frame)

		highlightingClipView.alpha = 0
		highlightingClipView.clipsToBounds = true
		highlightingClipView.layer.cornerRadius = 6
		highlightingClipView.addSubview(highlightingView, filling: .superview)

		imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)

		selectedBackgroundView = UIView()
		contentView.addSubview(highlightingClipView, filling: .superview, insets: .horizontally(0, vertically: 8))
		contentView.addSubview(contentHostingView, filling: .superview)
		contentHostingView.addSubview(selectionView)
		installConstraints()

		isAccessibilityElement = true
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIAccessibility
	override var accessibilityLabel: String? {
		get { element?.accessibilityLabel ?? labelForAccessibility ?? super.accessibilityLabel }
		set { super.accessibilityLabel = newValue }
	}

	override var accessibilityHint: String? {
		get { element?.accessibilityLabel ?? super.accessibilityLabel }
		set { super.accessibilityLabel = newValue }
	}

	override var accessibilityValue: String? {
		get { element?.accessibilityValue ?? super.accessibilityValue }
		set { super.accessibilityValue = newValue }
	}

	override var accessibilityLanguage: String? {
		get { element?.accessibilityLanguage ?? super.accessibilityLanguage }
		set { super.accessibilityLanguage = newValue }
	}

	override var accessibilityIdentifier: String? {
		get { element?.accessibilityIdentifier ?? super.accessibilityIdentifier }
		set { super.accessibilityIdentifier = newValue }
	}
}
