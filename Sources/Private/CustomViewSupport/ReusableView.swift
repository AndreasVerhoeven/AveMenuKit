//
//  ReusableView.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

internal class ReusableView {
	var view: UIView?
	var presentedElement: PresentedMenuElement?
	var configuration: ReusableViewConfiguration?

	enum Kind {
		case header
		case fullRow
		case contentRow
		case trailingAccessory
	}

	let kind: Kind
	init(kind: Kind) {
		self.kind = kind
	}

	func apply(_ configuration: ReusableViewConfiguration?, for presentedElement: PresentedMenuElement, cache: ReusableViewCache, parentView: UIView) {
		self.apply(configuration, for: presentedElement, cache: cache) { oldView, newView in
			oldView?.removeFromSuperview()
			guard let newView else { return }
			parentView.addSubview(newView, filling: .superview)
		}
	}

	func apply(_ configuration: ReusableViewConfiguration?, for presentedElement: PresentedMenuElement, cache: ReusableViewCache, installer: Installer? = nil) {
		let currentRealReuseIdentifier = self.configuration?.reuseIdentifier ?? self.presentedElement?.id
		let newReuseIdentifier = configuration?.reuseIdentifier ?? presentedElement.id

		if currentRealReuseIdentifier != newReuseIdentifier {
			// we can't reuse the current view, get a new one

			// we need to get a new view
			let oldView = view
			let newView = cache.dequeueReusableView(for: kind, reuseIdentifier: newReuseIdentifier, presentedElement: presentedElement) ??   configuration?.provider()
			if newView !== oldView {
				view = newView
				installer?(oldView, newView)

				if let oldView, let currentPresentedElement = self.presentedElement, let currentRealReuseIdentifier {
					cache.queueReusableView(oldView, for: kind, reuseIdentifier: currentRealReuseIdentifier, presentedElement: currentPresentedElement)
				}
			}
		}

		self.presentedElement = presentedElement
		self.configuration = configuration
	}

	typealias Installer = (_ oldView: UIView?, _ newView: UIView?) -> Void

	func update(metrics: MenuMetrics, animated: Bool) {
		guard let view else { return }
		configuration?.updater(view, metrics, animated)
	}
}
