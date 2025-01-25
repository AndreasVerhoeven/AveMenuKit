//
//  SearchCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 14/01/2025.
//

import UIKit
import AutoLayoutConvenience
import UIKitAnimations

class MenuSearchCell: MenuBaseCell {
	let searchBar = UISearchBar()

	// MARK: - BaseCell
	override func update(animated: Bool) {
		guard let element = element as? SearchField else { return }

		if element.placeholder != nil {
			searchBar.placeholder = element.placeholder
		}

		if searchBar.text != element.searchText {
			searchBar.text = element.searchText
		}

		searchBar.isUserInteractionEnabled = element.isEnabled
		UIView.performAnimationsIfNeeded(animated: animated) {
			self.searchBar.alpha = (element.isEnabled ? 1 : 0)
		}

		if element.shouldAutomaticallyFocusOnAppearance == true && element.didAutoFocus == false {
			element.didAutoFocus = true
			DispatchQueue.main.async { [searchBar] in
				searchBar.becomeFirstResponder()
			}
		}
	}

	// MARK: - UITableViewCell
	required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		searchBar.searchBarStyle = .minimal
		searchBar.delegate = self
		contentView.addSubview(searchBar, filling: .superview)
	}
}

extension MenuSearchCell: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		(element as? SearchField)?.setSearchTextFromSearchField(searchText)
	}
}
