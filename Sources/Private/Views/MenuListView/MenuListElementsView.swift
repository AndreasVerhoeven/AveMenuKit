//
//  MenuListElementsView.swift
//  Menu
//
//  Created by Andreas Verhoeven on 14/01/2025.
//

import UIKit
import AveDataSource

extension MenuListView {
	final class ElementsListView: UIView {
		let tableView = UITableView(frame: .zero, style: .plain)

		var isHeader = false
		var isOrderInverted = false
		var isScrolledPastTop: Bool { tableView.contentOffset.y > 0 }
		var lastIsScrolledPastTopValue = false
		var canPinToBottom = true
		var didScroll = false
		var isSubMenu = false
		var hasScrolledPastTopChangeCallback: (() -> Void)?

		var highlightedMenuElementId: MenuElement.ID? {
			didSet {
				guard highlightedMenuElementId != oldValue else { return }
				updateVisibleCells()
			}
		}

		var showsAsOpenedForMenuItem: MenuElement? {
			didSet {
				guard showsAsOpenedForMenuItem?.id != oldValue?.id else { return }
				updateVisibleCells()
			}
		}

		var shouldLastHeaderItemHaveSeparator = false
		var lastHeaderItemCanHaveSeparator = false

		var maximumHeight: CGFloat = 835 {
			didSet {
				guard maximumHeight != oldValue else { return }
				setNeedsLayout()
				layoutIfNeeded()
				tableView.setNeedsLayout()
			}
		}

		func update(items: [PresentedMenuElement], animated: Bool) {
			let menuHasLeadingAccessory = isSubMenu || items.contains { $0.element.wantsLeadingInset }

			for (offset, item) in items.enumerated() {
				item.menuHasLeadingAccessory = menuHasLeadingAccessory
				if offset < items.count - 1 {
					item.shouldShowSeparator = (item.element.canShowSeparator == true && items[offset + 1].element.canShowSeparator == true)
				} else {
					item.shouldShowSeparator = isHeader
				}
			}

			dataSource.apply(items: items, animated: animated)
			updateLastHeaderCellSeparator(animated: animated)
			pinToBottomIfNeeded(animated: animated)
		}

		func update(animated: Bool) {
			dataSource.updateCells(animated: animated)
			updateLastHeaderCellSeparator(animated: animated)
		}

		func frame(for menuItemId: MenuElement.ID?) -> ElementFrame? {
			guard let indexPath = dataSource.firstIndexPathForItem(matching: { $0.id == menuItemId }) else { return nil }
			let frame = tableView.rectForRow(at: indexPath)
			let convertedFrame = tableView.convert(frame, to: self)

			let visibleFrame = convertedFrame.intersection(CGRect(origin: .zero, size: bounds.size))
			return ElementFrame(
				frame: convertedFrame,
				visibleFrame: visibleFrame.isNull ? convertedFrame : visibleFrame
			)
		}

		func menuItem(at point: CGPoint) -> MenuElement? {
			guard self.point(inside: point, with: nil) == true else { return nil }
			let pointInTableViewCoordinates = tableView.convert(point, from: self)
			guard let indexPath = tableView.indexPathForRow(at: pointInTableViewCoordinates) else { return nil }
			guard let cell = tableView.cellForRow(at: indexPath) as? MenuBaseCell else { return nil }
			let pointInCellCoordinates = cell.convert(pointInTableViewCoordinates, from: tableView)
			return cell.menuElement(for: pointInCellCoordinates)
		}

		func stopScrolling() {
			tableView.panGestureRecognizer.stopRecognizing()
		}

		func updateLastHeaderCellSeparator(animated: Bool) {
			let numberOfItems = tableView.numberOfRows(inSection: 0)
			guard numberOfItems > 0 else { return }

			guard let cell = tableView.cellForRow(at: IndexPath(row: numberOfItems - 1, section: 0)) else { return }
			updateLastHeaderCellSeparator(cell, animated: true)
		}

		// MARK: - Privates
		private let reusableViewCache = ReusableViewCache()
		private lazy var registeredCellClasses = Set<String>()

		private lazy var dataSource = SingleSectionTableViewDataSource<PresentedMenuElement>(tableView: tableView, cellProvider: { [weak self] tableView, item, indexPath in
			guard let self else { return nil }

			let cellClass = item.element.elementTableViewCellClass
			let reuseIdentifier = NSStringFromClass(cellClass)
			if registeredCellClasses.contains(reuseIdentifier) == false {
				tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
			}
			return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		})

		private func updateVisibleCells() {
			guard bounds.height > 0 else { return }

			for cell in tableView.visibleCells {
				updateCell(cell)
			}
		}

		private func updateCell(_ cell: UITableViewCell) {
			guard let cell = cell as? MenuBaseCell else { return }
			cell.highlightedMenuElementId = highlightedMenuElementId
			cell.showsAsOpened = (cell.element?.id == showsAsOpenedForMenuItem?.id)
		}

		private func updateLastHeaderCellSeparator(_ cell: UITableViewCell, animated: Bool) {
			guard isHeader == true else { return }
			guard let cell = cell as? MenuBaseCell else { return }
			guard let element = cell.element else { return }
			guard element.id == dataSource.currentSnapshot.items.last?.id else { return }

			let shouldShowBottomSeparator = (element.canShowSeparator == true && (lastHeaderItemCanHaveSeparator == true || shouldLastHeaderItemHaveSeparator == true))

			if animated == true {
				UIView.animate(withDuration: 0.25, delay: 0, options: .allowUserInteraction, animations: {
					cell.showsBottomSeparator = shouldShowBottomSeparator
				})
			} else {
				cell.showsBottomSeparator = shouldShowBottomSeparator
			}
		}

		public func pinToBottomIfNeeded(animated: Bool) {
			guard isHeader == false else { return }
			guard isOrderInverted == true else { return }
			guard tableView.contentSize.height > bounds.height else { return }
			guard didScroll == false else { return }
			guard canPinToBottom == true else { return }
			tableView.setContentOffset(CGPoint(x: 0, y: max(0, tableView.contentSize.height - bounds.height)), animated: animated)
		}

		// MARK: - UIView
		override var intrinsicContentSize: CGSize {
			guard dataSource.currentSnapshot.hasItems == true else { return .zero }
			
			setNeedsLayout()
			layoutIfNeeded()
			tableView.layoutIfNeeded()
			return CGSize(width: UIView.noIntrinsicMetric, height: tableView.contentSize.height)
		}

		override func layoutSubviews() {
			super.layoutSubviews()
			tableView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: maximumHeight)
			tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: max(0, maximumHeight - bounds.height), right: 0)
			pinToBottomIfNeeded(animated: false)
		}

		override init(frame: CGRect) {
			super.init(frame: frame)

			tableView.alwaysBounceVertical = false
			tableView.backgroundColor = .clear
			tableView.separatorStyle = .none
			tableView.delegate = self
			tableView.contentInsetAdjustmentBehavior = .never
			tableView.layer.allowsGroupOpacity = false
			addSubview(tableView)

			layer.allowsGroupOpacity = false

			if #available(iOS 15, *) {
				tableView.sectionHeaderHeight = 0
				tableView.sectionHeaderTopPadding = 0
			}

			dataSource.cellUpdater = { [weak self] tableView, cell, item, indexPath, animated in
				guard let self else { return }
				guard let cell = cell as? MenuBaseCell else { return }
				cell.backgroundColor = .clear

				cell.reusableViewCache = reusableViewCache
				cell.showsBottomSeparator = item.shouldShowSeparator
				cell.menuHasLeadingAccessories = item.menuHasLeadingAccessory
				cell.highlightedMenuElementId = highlightedMenuElementId
				cell.showsAsOpened = (item.id == showsAsOpenedForMenuItem?.id)
				cell.setPresentedMenuElement(item, animated: animated)
			}
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("not implemented")
		}
	}
}

extension MenuListView.ElementsListView: UITableViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard lastIsScrolledPastTopValue != isScrolledPastTop else { return }
		lastIsScrolledPastTopValue = isScrolledPastTop
		hasScrolledPastTopChangeCallback?()
	}

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		didScroll = true
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		didScroll = round(tableView.contentOffset.y) < round(tableView.contentSize.height - bounds.height)
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if decelerate == false {
			didScroll = round(tableView.contentOffset.y) < round(tableView.contentSize.height - bounds.height)
		}
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = cell as? MenuBaseCell else { return }

		updateCell(cell)
		updateLastHeaderCellSeparator(cell, animated: false)
	}
}
