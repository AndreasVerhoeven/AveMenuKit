//
//  MenuBaseCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit

/// Base cell that provides highlighting and a separator
class MenuBaseCell: UITableViewCell {
	let highlightingView = UIView.menuHighlightingView()
	let separatorView = UIView.menuSeparatorView()

	// MARK: Standard Configuration
	var menuHasLeadingAccessories = false
	var reusableViewCache: ReusableViewCache!

	// MARK: PresentedElement
	private(set) var presentedMenuElement: PresentedMenuElement?
	func setPresentedMenuElement(_ presentedElement: PresentedMenuElement, animated: Bool) {
		self.presentedMenuElement = presentedElement
		showsBottomSeparator = presentedElement.shouldShowSeparator

		update(animated: animated)
		updateLayout(animated: animated)
	}

	// Convenience helper
	var element: MenuElement? {
		return presentedMenuElement?.element
	}

	// MARK: Highlighting
	var highlightedMenuElementId: MenuElement.ID? {
		didSet {
			showsHighlighted = element.flatMap { $0.id == highlightedMenuElementId } ?? false
		}
	}

	var showsHighlighted = false {
		didSet {
			guard showsHighlighted != oldValue else { return }
			highlightingView.isHidden = (showsHighlighted == false)
			separatorView.isHidden = (showsHighlighted == true)
		}
	}


	// MARK: Getting menuItem from a Point
	func menuElement(for point: CGPoint) -> MenuElement? {
		guard let element else { return nil }
		return element.canBeHighlighted == true ? element : nil
	}

	// MARK: - View Flags
	var showsAsOpened = false {
		didSet {
			guard showsAsOpened != oldValue else { return }
			update(animated: false)
		}
	}

	var showsBottomSeparator = false {
		didSet {
			guard showsBottomSeparator != oldValue else { return }
			separatorView.alpha = (showsBottomSeparator == true ? 1 : 0)
		}
	}

	// MARK: Updating
	func update(animated: Bool) {}
	func updateLayout(animated: Bool) {}

	// MARK: - UITableViewCell
	override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		highlightingView.isHidden = true
		separatorView.alpha = 0
		separatorView.constrainedFixedHeight = 1.0 / UIScreen.main.scale

		selectedBackgroundView = UIView()
		contentView.addSubview(
			.verticallyStacked(
				highlightingView.wrapped(in: .superview),
				separatorView
			),
			filling: .superview
		)

		separatorView.superview?.bringSubviewToFront(separatorView)
		separatorView.layer.zPosition = 10
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIView
	override func didMoveToWindow() {
		super.didMoveToWindow()

		if let scale = window?.screen.scale {
			separatorView.constrainedFixedHeight = 1.0 / scale
		}
	}
}
