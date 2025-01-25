//
//  InlineGroup.swift
//  Menu
//
//  Created by Andreas Verhoeven on 12/01/2025.
//

import UIKit
import AutoLayoutConvenience
import AveDataSource

class InlineGroupCell: MenuBaseCell {
	let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

	lazy var dataSource = SingleSectionCollectionViewDataSource<PresentedMenuElement>(collectionView: collectionView) { collectionView, item, indexPath in
		if item.element is Action || item.element is SubMenuElement {
			return collectionView.dequeueReusableCell(withReuseIdentifier: "ActionCell", for: indexPath)
		} else if item.element is LazyMenuElement {
			return collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath)
		} else {
			fatalError("not implemented!")
		}
	}

	private (set) var size: Menu.ElementSize = .medium

	override var highlightedMenuElementId: MenuElement.ID? {
		didSet {
			guard highlightedMenuElementId != oldValue else { return }
			for cell in collectionView.visibleCells {
				updateSelection(cell: cell)
			}
		}
	}

	func setMenuItems(_ items: [PresentedMenuElement], size: Menu.ElementSize, animated: Bool) {
		self.size = size
		updateSize()
		dataSource.apply(items: items, animated: animated)
		collectionView.collectionViewLayout.invalidateLayout()
	}

	override func update(animated: Bool) {
		guard let group = element as? InlineGroup else { return }

		let presentedMenuElements = group.elements.map { PresentedMenuElement(element: $0) }
		presentedMenuElements.last?.shouldShowSeparator = false
		setMenuItems(presentedMenuElements, size: group.size, animated: animated)
	}

	// MARK: - Privates
	private func updateSize() {
		let baseHeight: CGFloat = switch size {
		case .medium, .large, .automatic: 66
			case .small: 44
		}
		collectionView.constrainedFixedHeight = UIFontMetrics(forTextStyle: .footnote).scaledValue(for: baseHeight)
	}

	private func updateSelection(cell: UICollectionViewCell) {
		guard let cell = cell as? BaseInlineCell else { return }
		cell.showsAsHighlighted = (cell.menuItem?.id == highlightedMenuElementId)
	}

	// MARK: - BaseCell
	override func menuElement(for point: CGPoint) -> MenuElement? {
		let convertedPoint = collectionView.convert(point, from: self)
		guard let indexPath = collectionView.indexPathForItem(at: convertedPoint) else { return nil }
		guard let cell = collectionView.cellForItem(at: indexPath) as? BaseInlineCell else { return nil }
		guard let menuItem = cell.menuItem else { return nil }
		return menuItem.canBeHighlighted == true ? menuItem : nil
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		dataSource.cellUpdater = { [weak self] tableView, cell, item, indexPath, animated in
			guard let self else { return }
			guard let cell = cell as? BaseInlineCell else { return }
			cell.size = size
			cell.backgroundColor = .clear
			cell.setPresentedElement(item, animated: animated)
			updateSelection(cell: cell)
		}

		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.scrollDirection = .horizontal
		collectionView.collectionViewLayout = layout
		collectionView.bounces = false
		collectionView.contentInsetAdjustmentBehavior = .never
		collectionView.delegate = self

		collectionView.register(ActionInlineCell.self, forCellWithReuseIdentifier: "ActionCell")
		collectionView.register(LoadingInlineCell.self, forCellWithReuseIdentifier: "LoadingCell")
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

extension InlineGroupCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let itemCount = dataSource.currentSnapshot.items.count
		let maxNumberOfItemsTouse = min(max(itemCount, 1), size.maximumOfElementsPerRow)
		return CGSize(width: bounds.width / CGFloat(maxNumberOfItemsTouse), height: bounds.height)
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		updateSelection(cell: cell)
	}
}
