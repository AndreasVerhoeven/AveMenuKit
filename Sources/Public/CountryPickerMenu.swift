//
//  CountryPickerMenu.swift
//  Demo
//
//  Created by Andreas Verhoeven on 02/02/2025.
//

import UIKit

/// Element that shows a full menu that allows the user to pick a country from a list.
///
/// Demonstrates how to implement a custom element that consists of multiple different other elements:
///  - we use `CustomContentViewAction` to have a emoji as image using a `UILabel`
///  - we subclass `Group` to hide our implementation and only expose the properties we want to expose
///		(e.g. users of this element cannot override the custom view)
public class CountryPickerMenu: Group, MenuLeaf {
	/// the list of allowed country codes - if nil, the default list of all known country codes will be used
	open var countryCodes: Set<String>? {
		didSet {
			guard countryCodes != oldValue else { return }
			createCountryElementsIfNeeded()
			setNeedsUpdate()
		}
	}

	/// the selected country code
	open var selectedCountryCode: String? {
		didSet {
			guard selectedCountryCode != oldValue else { return }
			updateCountryElements()
			setNeedsUpdate()
		}
	}

	/// the text that will be used when there is no selection yet
	open var noSelectionText: String? {
		didSet {
			guard noSelectionText != oldValue else { return }
			updateSubTitle()
		}
	}

	/// handler called when the selectedCountryCode was changed via user interaction
	open var handler: ((String?) -> Void)?

	// MARK: MenuLeaf
	/// If false, this action cannot be invoked by the user
	open var isEnabled: Bool {
		get { subMenu.isEnabled }
		set { subMenu.isEnabled = newValue }
	}

	/// if true, this action will be shown as destructive, e.g. with red text.
	open var isDestructive: Bool {
		get { subMenu.isDestructive }
		set { subMenu.isDestructive = newValue }
	}

	/// The optional title for this element
	open var title: String? {
		get { subMenu.title }
		set { subMenu.title = newValue }
	}

	/// The optional image for this element
	open var image: UIImage? {
		get { subMenu.image }
		set { subMenu.image = newValue }
	}

	public init(title: String? = nil, image: UIImage? = nil, isEnabled: Bool = true, isDestructive: Bool = false, noSelectionText: String? = nil, handler: ((String?) -> Void)? = nil) {
		self.noSelectionText = noSelectionText
		self.handler = handler
		super.init()

		subMenu.onlyDismissesSubMenu = true
		subMenu.title = title
		subMenu.image = image
		subMenu.isEnabled = isEnabled
		subMenu.isDestructive = isDestructive
		subMenu.headers = [search]

		createCountryElementsIfNeeded()
	}

	// MARK: Group
	
	public override var displayedElements: [MenuElement] {
		return [subMenu]
	}

	// MARK: - Privates
	/// the menu we show
	private let subMenu = Menu(children: [])

	/// the country elements we show
	private var countryElements = [CountryElement]()

	/// a cache of existing country elements by code, so that we won't recreate them when not needed
	private var existingCountryCodeElements = [String: CountryElement]()

	/// our search
	private lazy var search = SearchField(placeholder: "Search Countries", searchText: "") { [weak self] searchText in
		self?.updateCountryElements()
	}

	/// creates and assigns CountryElements as our subMenus children
	private func createCountryElementsIfNeeded() {
		let countryCodesToUse = countryCodes ?? Set(NSLocale.isoCountryCodes)

		countryElements = countryCodesToUse.map { countryCode in
			let uppercasedCountryCode = countryCode
			if let element = existingCountryCodeElements[uppercasedCountryCode] {
				// we got an element already, reuse it
				return element
			} else {
				// we need to create a new element for this country code
				let element = CountryElement(countryCode: uppercasedCountryCode, handler: { [weak self] element in
					guard let self else { return }
					selectedCountryCode = element.countryCode
					handler?(selectedCountryCode)
				})
				existingCountryCodeElements[uppercasedCountryCode] = element
				return element
			}
		}.sorted { $0.localizedCountryName.localizedCaseInsensitiveCompare($1.localizedCountryName) == .orderedAscending }

		updateCountryElements()
		subMenu.children = countryElements
	}

	/// updates the subtitle
	private func updateCountryElements() {
		let uppercasedSelectedCountryCode = selectedCountryCode?.uppercased()
		let searchText = search.searchText

		// we dynamically update the visibility and selection state of our country elements based on the current search text
		// and `selectedCountryCode` field. This will allow the user to filter the list by typing
		for element in countryElements {
			element.isHidden = (searchText.isEmpty == false && element.localizedCountryName.localizedCaseInsensitiveContains(searchText) == false)
			element.isSelected = (uppercasedSelectedCountryCode == element.countryCode)
		}

		updateSubTitle()
	}

	/// updates the subtitle
	private func updateSubTitle() {
		let uppercasedSelectedCountryCode = selectedCountryCode?.uppercased()
		subMenu.subtitle = uppercasedSelectedCountryCode.flatMap { existingCountryCodeElements[$0]?.localizedCountryName } ?? noSelectionText
	}
}
