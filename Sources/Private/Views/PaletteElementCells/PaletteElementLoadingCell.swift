//
//  PaletteElementLoadingCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

class PaletteElementLoadingCell: UICollectionViewCell {
	let spinner = UIActivityIndicatorView(style: .medium)

	var presentedMenuElement: PresentedMenuElement?
	var element: MenuElement? { presentedMenuElement?.element }

	// MARK: - UIView
	override func didMoveToWindow() {
		super.didMoveToWindow()
		spinner.startAnimating()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(spinner, filling: .superview)
		spinner.startAnimating()

		accessibilityLabel = NSLocalizedString("CONTEXT_MENU_LOADING", tableName: "Localizable", bundle: Bundle(for: UIApplication.classForCoder()), comment: "")
		isAccessibilityElement = true

	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIAccessibility
	override var accessibilityLabel: String? {
		get { element?.accessibilityLabel ?? super.accessibilityLabel }
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
