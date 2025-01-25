//
//  BaseInlineCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience

class BaseInlineCell: UICollectionViewCell {
	let highlightingView = UIView.menuHighlightingView()
	let separatorView = UIView.menuSeparatorView()

	var size: Menu.ElementSize = .medium
	private(set) var presentedElement: PresentedMenuElement?
	var menuItem: MenuElement? { presentedElement?.element }

	func setPresentedElement(_ element: PresentedMenuElement, animated: Bool) {
		self.presentedElement = element
		showsTrailingSeparator = element.shouldShowSeparator
		update(animated: animated)
	}

	func update(animated: Bool) {}

	var showsAsHighlighted = false {
		didSet {
			guard showsAsHighlighted != oldValue else { return }
			highlightingView.alpha = (showsAsHighlighted == true ? 1 : 0)
		}
	}

	var showsTrailingSeparator = false {
		didSet {
			guard showsTrailingSeparator != oldValue else { return }
			separatorView.isHidden = (showsTrailingSeparator == false)
		}
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if let scale = window?.screen.scale {
			separatorView.constrainedFixedWidth = 1.0 / scale
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		highlightingView.alpha = 0
		separatorView.isHidden = true

		selectedBackgroundView = UIView()
		contentView.addSubview(
			.horizontallyStacked(
				highlightingView,
				separatorView
			),
			filling: .superview
		)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
