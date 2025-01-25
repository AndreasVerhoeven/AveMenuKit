//
//  ContentHostingCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience

/// Hosts content with a leading an trailing accessory
class MenuContentHostingCell: MenuBaseCell {
	let menuContentView = UIView()

	// MARK: - Internal
	internal var leadingAccessoryView: UIImageView? { nil }
	internal var trailingAccessoryView: UIView? { nil }
	internal var currentlyUsedLayoutMetrics = MenuMetrics()
	internal var isShowingTrailingAccessory = false

	// MARK: - Privates
	private var leadingAccessoryConstraints: ConstraintsList?
	private var trailingAccessoryConstraints: ConstraintsList?
	private var trailingAccessoryIsSymbolImage: Bool?

	private func addAccessoriesToViewIfNeeded() {
		if let leadingAccessoryView, leadingAccessoryView.superview == nil {
			leadingAccessoryConstraints = contentView.addSubview(leadingAccessoryView, pinning: .center, to: .leadingCenter)
		}

		if let trailingAccessoryView, trailingAccessoryView.superview == nil {
			trailingAccessoryConstraints = contentView.addSubview(trailingAccessoryView, pinning: .center, to: .trailingCenter)
			(trailingAccessoryView as? UIImageView)?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
		}
	}

	// MARK: BaseCell
	override func updateLayout(animated: Bool) {
		addAccessoriesToViewIfNeeded()

		let metrics = MenuMetrics(with: traitCollection, menuHasLeadingAccessories: menuHasLeadingAccessories)

		let wantsTrailingAccessory = (trailingAccessoryView?.isHidden ?? true) == false
		let shouldShowTrailingAccessory = (metrics.canShowTrailingAccessory == true && wantsTrailingAccessory == true)


		let needsUpdate = (isShowingTrailingAccessory != shouldShowTrailingAccessory) || metrics.hasDifferentLayout(from: currentlyUsedLayoutMetrics)
		currentlyUsedLayoutMetrics = metrics
		isShowingTrailingAccessory = shouldShowTrailingAccessory

		if leadingAccessoryConstraints?.centerX?.constant != metrics.leadingAccessoryCenterXOffset {
			leadingAccessoryConstraints?.centerX?.constant = metrics.leadingAccessoryCenterXOffset
		}

		if trailingAccessoryConstraints?.centerX?.constant != -metrics.trailingAccessoryCenterXOffset {
			trailingAccessoryConstraints?.centerX?.constant = -metrics.trailingAccessoryCenterXOffset
		}

		if needsUpdate == true {
			menuContentView.replaceStoredConstraints {
				if shouldShowTrailingAccessory, let trailingAccessoryView {
					contentView.addSubview(menuContentView, pinningLeadingTo: .leading, of: .superview, trailingTo: .centerX, of: .relative(trailingAccessoryView), insets: metrics.effectiveInsetsBetweenLeadingEdgeAndTrailingAccessoryCenter)
				} else {
					contentView.addSubview(menuContentView, filling: .superview, insets: metrics.contentInsets)
				}
			}
		}

		if let leadingAccessoryView {
			leadingAccessoryView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold, scale: .small)
		}

		if let trailingAccessoryView = trailingAccessoryView as? UIImageView {
			let isSymbolImage = trailingAccessoryView.image?.isSymbolImage ?? false
			if needsUpdate == true || isSymbolImage != trailingAccessoryIsSymbolImage {
				trailingAccessoryIsSymbolImage = isSymbolImage

				trailingAccessoryView.replaceStoredConstraints(for: .maximumSize) {
					if isSymbolImage == false {
						trailingAccessoryView.constrain(size: .atMost(metrics.maximumIconSize))
					}
				}
			}
		}
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		menuContentView.addStoredConstraints {
			contentView.addSubview(menuContentView, filling: .superview)
		}

		updateLayout(animated: false)
	}

	// MARK: - UIView
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateLayout(animated: false)
	}
	}
