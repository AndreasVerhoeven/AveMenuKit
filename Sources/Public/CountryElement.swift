//
//  CountryElement.swift
//  Demo
//
//  Created by Andreas Verhoeven on 02/02/2025.
//

import UIKit

/// Shows a country as a selectable element - the flag is rendered as an emoji on the place of the image
///
/// Demonstrates how to implement a custom element:
///  - we use `CustomContentViewAction` to have a emoji as image using a `UILabel`
///  - we subclass `Group` to hide our implementation and only expose the properties we want to expose
///		(e.g. users of this element cannot override the custom view)
public class CountryElement: Group, MenuActionLeaf, SelectableMenuActionLeaf {
	// the 2-letter country code of the country to show
	open var countryCode: String {
		didSet {
			guard countryCode != oldValue else { return }
			_localizedCountryName = nil
			_emoji = nil
			setNeedsUpdate()
		}
	}

	// MARK: MenuLeaf
	/// If false, this action cannot be invoked by the user
	open var isEnabled: Bool {
		get { actualElement.isEnabled }
		set { actualElement.isEnabled = newValue }
	}

	/// if true, this action will be shown as destructive, e.g. with red text.
	open var isDestructive: Bool {
		get { actualElement.isDestructive }
		set { actualElement.isDestructive = newValue }
	}

	// MARK: SelectableMenuActionLeaf
	/// if true, a checkmark will be shown next to the action
	open var isSelected: Bool {
		get { actualElement.isEnabled }
		set { actualElement.isSelected = newValue }
	}

	/// if true, tapping on this action will not dismiss the menu
	open var keepsMenuPresented: Bool {
		get { actualElement.keepsMenuPresented }
		set { actualElement.keepsMenuPresented = newValue }
	}

	/// will be called when the action is invoked
	open var handler: ((CountryElement) -> Void)?

	public override func perform() {
		handler?(self)
	}

	public init(countryCode: String, isEnabled: Bool = true, isDestructive: Bool = false, isSelected: Bool = false, keepsMenuPresented: Bool = false, handler: ((CountryElement) -> Void)? = nil) {
		self.countryCode = countryCode
		self.handler = handler
		super.init()

		actualElement.contentView = .reusableView(reuseIdentifier: Self.contentViewReuseIdentifier, viewClass: UILabel.self, updater: { [weak self] label, metrics, animated in
			guard let self else { return }
			label.font = metrics.contentFont
			label.numberOfLines = metrics.maximumNumberOfLines
			label.textColor = metrics.contentColor
			label.setText(localizedCountryName, animated: animated)
		})

		actualElement.trailingAccessoryView = .reusableView(reuseIdentifier: Self.accessoryViewReuseIdentifier, viewClass: UILabel.self, updater: { [weak self] label, metrics, animated in
			guard let self else { return }
			label.font = metrics.contentFont
			label.textColor = metrics.contentColor
			label.numberOfLines = 1
			label.textAlignment = .center
			label.text = emoji
		})

		actualElement.isEnabled = isEnabled
		actualElement.isDestructive = isDestructive
		actualElement.isSelected = isSelected
		actualElement.keepsMenuPresented = keepsMenuPresented
		actualElement.handler = { [weak self] _ in self?.perform() }
	}

	// MARK: - Group
	public override var displayedElements: [MenuElement] {
		return [actualElement]
	}


	// MARK: - Privates
	private var _countryCode: String?
	private var _localizedCountryName: String?
	private var _emoji: String?

	static private let contentViewReuseIdentifier = UUID().uuidString
	static private let accessoryViewReuseIdentifier = UUID().uuidString
	private lazy var actualElement = CustomContentViewAction()

	internal static let emojiOverrides = [
		"CQ": "🇺🇳",
		"UK": "🇬🇧",
	]

	internal var localizedCountryName: String {
		if let _localizedCountryName {
			return _localizedCountryName
		}

		let countryName = (Locale.current as NSLocale).localizedString(forCountryCode: countryCode) ?? countryCode
		_localizedCountryName = countryName
		return countryName
	}

	private var emoji: String {
		if let _emoji {
			return _emoji
		}

		let uppercasedCountryCode = countryCode.uppercased()
		let emoji = Self.emojiOverrides[uppercasedCountryCode] ?? uppercasedCountryCode.unicodeScalars.lazy.map { 127397 + $0.value }.compactMap { UnicodeScalar($0) }.map { String($0) }.joined()
		_emoji = emoji
		return String(emoji)
	}
}
