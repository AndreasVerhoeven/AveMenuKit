//
//  Search.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// Shows a search field inside of a menu. For example, you can use this to make a user filter 
/// down a submenu with a lot of items quickly. It's recommended to show it as a header in (sub)menu.
open class SearchField: MenuElement, NonSelectableMenuLeaf {
	/// the placeholder to show in the search field
	open var placeholder: String? {
		didSet {
			guard placeholder != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// the search text to display by default. Will be updated when the user
	/// interacts with the search field.
	open var searchText = "" {
		didSet {
			guard placeholder != oldValue else { return }
			guard ignoreSearchTextUpdateCount <= 0 else { return }
			originalSearchText = searchText
			setNeedsUpdate()
		}
	}

	/// If false, users cannot interact with the search field
	open var isEnabled = true {
		didSet {
			guard isEnabled != oldValue else { return }
			setNeedsUpdate()
		}
	}

	/// if true, when the search field is shown for the first time in a menu, it will auto become first responder.
	open var shouldAutomaticallyFocusOnAppearance = false

	/// the callback called when `searchText` changes due to user input.
	open var updater: Updater?
	public typealias Updater = (String) -> Void

	public init(placeholder: String? = nil, searchText: String = "", updater: Updater? = nil) {
		self.placeholder = placeholder
		self.searchText = searchText
		self.updater = updater
	}

	// MARK: - Internal
	internal var didAutoFocus = false
	internal var originalSearchText: String?

	internal func setSearchTextFromSearchField(_ searchText: String) {
		ignoreSearchTextUpdateCount += 1
		defer { ignoreSearchTextUpdateCount -= 1 }
		self.searchText = searchText
		updater?(searchText)
	}

	// MARK: - Privates
	private var ignoreSearchTextUpdateCount = 0

	// MARK: - MenuElement
	override internal var isLeaf: Bool { true }
	override internal var elementTableViewCellClass: MenuBaseCell.Type { MenuSearchCell.self }

	override func cleanupAfterDisplay() {
		didAutoFocus = false

		ignoreSearchTextUpdateCount += 1
		defer { ignoreSearchTextUpdateCount -= 1 }
		searchText = originalSearchText ?? ""
	}
}

extension SearchField {
	func automaticallyFocusOnAppearance() -> Self {
		shouldAutomaticallyFocusOnAppearance = true
		return self
	}
}
