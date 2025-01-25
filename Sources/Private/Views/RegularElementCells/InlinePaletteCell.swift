//
//  InlinePaletteCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 23/01/2025.
//

import UIKit
import AutoLayoutConvenience
import AveDataSource

class InlinePaletteCell: MenuBaseCell {
	let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

	lazy var dataSource = SingleSectionCollectionViewDataSource<PresentedMenuElement>(collectionView: collectionView) { collectionView, item, indexPath in
		if item.element is LoadingElement {
			return collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath)
		} else {
			return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
		}
	}

	override var highlightedMenuElementId: MenuElement.ID? {
		didSet {
			guard highlightedMenuElementId != oldValue else { return }
			for cell in collectionView.visibleCells {
				updateSelection(cell: cell)
			}
		}
	}

	weak var lastRegisteredWithDelegate: AnyObject?

	var paletteSelectionStyle = Menu.PaletteSelectionStyle.tint

	func setMenuItems(_ items: [PresentedMenuElement], animated: Bool) {
		updateSize()
		dataSource.apply(items: items, animated: animated)
		collectionView.collectionViewLayout.invalidateLayout()
	}

	func registerScrollViewIfNeeded() {
		if lastRegisteredWithDelegate !== element?.delegate {
			element?.delegate?.registerScrollView(collectionView)
			lastRegisteredWithDelegate = element?.delegate
		}
	}

	override func update(animated: Bool) {
		guard let group = element as? InlinePalette else { return }

		paletteSelectionStyle = group.selectionStyle
		registerScrollViewIfNeeded()


		let presentedMenuElements = group.elements.map { PresentedMenuElement(element: $0) }
		presentedMenuElements.last?.shouldShowSeparator = false
		setMenuItems(presentedMenuElements, animated: animated)
	}

	// MARK: - Privates
	private func updateSize() {
		collectionView.constrainedFixedHeight = UIFontMetrics(forTextStyle: .body).scaledValue(for: 54)
	}

	private func updateSelection(cell: UICollectionViewCell) {
		guard let cell = cell as? PaletteElementContentCell else { return }
		cell.showsAsHighlighted = (cell.menuItem?.id == highlightedMenuElementId)
	}

	// MARK: - BaseCell
	override func menuElement(for point: CGPoint) -> MenuElement? {
		let convertedPoint = collectionView.convert(point, from: self)
		guard let indexPath = collectionView.indexPathForItem(at: convertedPoint) else { return nil }
		guard let cell = collectionView.cellForItem(at: indexPath) as? PaletteElementContentCell else { return nil }
		guard let menuItem = cell.menuItem else { return nil }
		return menuItem.canBeHighlighted == true ? menuItem : nil
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		dataSource.cellUpdater = { [weak self] tableView, cell, item, indexPath, animated in
			guard let self else { return }

			guard let cell = cell as? PaletteElementContentCell else { return }
			cell.backgroundColor = .clear
			cell.selectionStyle = paletteSelectionStyle
			cell.setPresentedElement(item, animated: animated)
			updateSelection(cell: cell)
		}

		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = .horizontal
		configuration.interSectionSpacing = 0

		let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] _, environment in
			let minimalWidth = UIFontMetrics(forTextStyle: .body).scaledValue(for: 54) - 16

			let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(minimalWidth), heightDimension: .fractionalHeight(1))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

			let layout = MenuItemLayout()
			_ = layout.updateFor(hasLeadingAccessory: self?.menuHasLeadingAccessories ?? false, hasTrailingAccessory: false, traitCollection: environment.traitCollection)
			var insets = layout.contentInset.with(vertical: 0)
			insets.leading = max(0, insets.leading - 8)

			// 4
			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = 0
			section.contentInsets = insets
			if #available(iOS 14, *) {
				section.contentInsetsReference = .none
			}
			return section
		}, configuration: configuration)

		collectionView.register(PaletteElementLoadingCell.self, forCellWithReuseIdentifier: "LoadingCell")
		collectionView.register(PaletteElementContentCell.self, forCellWithReuseIdentifier: "Cell")
		collectionView.collectionViewLayout = layout
		collectionView.contentInsetAdjustmentBehavior = .never
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.alwaysBounceVertical = false
		collectionView.alwaysBounceHorizontal = false
		collectionView.delegate = self

		collectionView.backgroundColor = .clear
		contentView.addSubview(collectionView, filling: .superview)
		updateSize()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}

	// MARK: - UIView
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateSize()
	}
}

extension InlinePaletteCell: UICollectionViewDelegate{
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		updateSelection(cell: cell)
	}
}
