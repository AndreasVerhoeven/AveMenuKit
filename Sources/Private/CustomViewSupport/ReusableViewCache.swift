//
//  ReusableViewCache.swift
//  Menu
//
//  Created by Andreas Verhoeven on 17/01/2025.
//

import UIKit

class ReusableViewCache {
	func dequeueReusableView(for kind: ReusableView.Kind, reuseIdentifier: String, presentedElement: PresentedMenuElement) -> UIView? {
		guard let lookup = cache[kind]?.reuseIdentifierToViewCache[reuseIdentifier] else { return nil }
		if let specificView = lookup.viewsByMenuElementId[presentedElement.id] {
			// we got a specific one
			lookup.viewsByMenuElementId.removeValue(forKey: presentedElement.id)
			return specificView
		} else if let first = lookup.viewsByMenuElementId.first {
			// no specific view for this element, but we got a matching re-use identifier
			lookup.viewsByMenuElementId.removeValue(forKey: first.key)
			return first.value
		} else {
			return nil
		}
	}

	func queueReusableView(_ view: UIView, for kind: ReusableView.Kind, reuseIdentifier: String, presentedElement: PresentedMenuElement) {
		let kindCache: KindCache
		if let value = cache[kind] {
			kindCache = value
		} else {
			kindCache = KindCache()
			cache[kind] = kindCache
		}

		let viewCache: ViewCache
		if let value = kindCache.reuseIdentifierToViewCache[reuseIdentifier] {
			viewCache = value
		} else {
			viewCache = ViewCache()
			kindCache.reuseIdentifierToViewCache[reuseIdentifier] = viewCache
		}

		viewCache.viewsByMenuElementId[presentedElement.id] = view
	}

	init() {
		memoryPressureSource = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
		memoryPressureSource.setEventHandler { [weak self] in
			self?.cache.removeAll()
		}
		memoryPressureSource.activate()
	}

	// MARK: - Privates
	private class ViewCache {
		var viewsByMenuElementId = [MenuElement.ID: UIView]()
	}

	private class KindCache {
		var reuseIdentifierToViewCache = [String: ViewCache]()
	}

	private var cache = [ReusableView.Kind: KindCache]()
	private let memoryPressureSource: DispatchSourceMemoryPressure
}
