//
//  LazyMenuElement.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// Use this if you have content to show in the menu that's is not yet available.
/// A "loading" indicator will be shown in the menu, until you provide the actual
/// content: the "loading" indicator will be replaced by the actual content.
open class LazyMenuElement: MenuElement {
	public typealias Completion = (_ elements: [MenuElement]) -> Void
	public typealias Provider = (_ completion: @escaping Completion) -> Void?

	/// This will be called to provide the actual content. When you have the content, call the passed in completion() with the content.
	open var provider: Provider? {
		didSet {
			loadedElements = nil
			isLoading = false
			currentLoadingIdentifier = nil
			setNeedsUpdate()
		}
	}

	/// If true, once we have provided content, it will be cached and the provider won't be called. If false,
	/// the provider will always be called to provide content when its menu is shown (again).
	open var shouldCache = false {
		didSet {
			guard shouldCache != oldValue else { return }
			setNeedsUpdate()
		}
	}

	public init(shouldCache: Bool = false, provider: @escaping Provider) {
		self.shouldCache = shouldCache
		self.provider = provider
	}

	// MARK: - Module Internal
	internal func prepareForPresentationInMenu(properties: MenuProperties) {
		loadElementsIfNeeded()
	}

	override func cleanupAfterDisplay() {
		guard shouldCache == false else { return }
		loadedElements = nil
		isLoading = false
	}

	override func actualMenuElements(properties: MenuProperties) -> [MenuElement] { 
		loadElementsIfNeeded()
		return loadedElements ?? [loadingElement]
	}

	// MARK: - Privates
	private var loadedElements: [MenuElement]?
	private var isLoading = false
	private var currentLoadingIdentifier: UUID?
	private lazy var loadingElement = LoadingElement()

	private func loadElementsIfNeeded() {
		guard loadedElements == nil && isLoading == false else { return }

		if let provider {
			let loadingIdentifier = UUID()
			currentLoadingIdentifier = loadingIdentifier

			isLoading = true
			provider { [weak self] elements in
				guard let self else { return }
				guard currentLoadingIdentifier == loadingIdentifier else { return }
				isLoading = false
				loadedElements = elements
				setNeedsUpdate()
			}
		} else {
			loadedElements = []
		}
	}
}
