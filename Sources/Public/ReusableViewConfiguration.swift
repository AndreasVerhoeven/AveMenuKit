//
//  ViewConfiguration.swift
//  Menu
//
//  Created by Andreas Verhoeven on 17/01/2025.
//

import UIKit

/// For elements that can take custom views, this provides
/// the configuration for such a view:
///
/// For performance reasons, views are reused (like
/// `UITableViewCells`.
///
/// We also split the providing of a view from updating it:
/// a `view` will  be created once when it is displayed, but
/// will be updated multiple times usually.
public struct ReusableViewConfiguration {
	/// The reuseidentifier - if `nil` this view
	/// will not be re-used and only be used for the same
	/// element every time.
	public var reuseIdentifier: String?

	/// provides the view to be displayed. Usually
	/// creates it. Views are cached using the `reuseIdentifier`
	public var provider: () -> UIView

	/// Called when a view needs to be updated.
	public var updater: (_ view: UIView, _ metrics: MenuMetrics, _ animated: Bool) -> Void

	/// Initializer : the View is strongly typed.
	public init<View: UIView>(
		reuseIdentifier: String? = nil,
		provider: @escaping () -> View,
		updater: @escaping (_ view: View, _ metrics: MenuMetrics, _ animated: Bool) -> Void
	) {
		self.reuseIdentifier = reuseIdentifier
		self.provider = { provider() }
		self.updater = { view, metrics, animated in
			guard let view = view as? View else { return }
			updater(view, metrics, animated)
		}
	}

	/// A reusable view. Views with the same `reuseIdentifier` will be
	/// reused if possible even between different elements.
	/// If a new view is needed, the provider is called.
	public static func reusableView<View: UIView>(
		reuseIdentifier: String,
		provider: @escaping () -> View,
		updater: @escaping (_ view: View, _ metrics: MenuMetrics, _ animated: Bool) -> Void
	) -> Self {
		return Self(reuseIdentifier: reuseIdentifier, provider: provider, updater: updater)
	}

	/// A reusable view of a given class. Views with the same `reuseIdentifier` will be
	/// reused if possible even between different elements.
	/// If a new view is needed, it will be created with the default `init()`.
	public static func reusableView<View: UIView>(
		reuseIdentifier: String,
		viewClass: View.Type,
		updater: @escaping (_ view: View, _ metrics: MenuMetrics, _ animated: Bool) -> Void
	) -> Self {
		return reusableView(reuseIdentifier: reuseIdentifier, provider: { View() }, updater: updater)
	}

	/// A view that is used within a single element - can be reused, but only by
	/// the same element.
	///
	/// If a new view is needed, the provider is called.
	public static func singleElementView<View: UIView>(
		provider: @escaping () -> View,
		updater: @escaping (_ view: View, _ metrics: MenuMetrics, _ animated: Bool) -> Void
	) -> Self {
		return Self(reuseIdentifier: nil, provider: provider, updater: updater)
	}

	/// A view of a specific class that is used within a single element - can be reused, but only by
	/// the same element.
	///
	/// reused if possible. If a new view is needed, it will be created with the default `init()`.
	public static func singleElementView<View: UIView>(
		viewClass: View.Type,
		updater: @escaping (_ view: View, _ metrics: MenuMetrics, _ animated: Bool) -> Void
	) -> Self {
		return Self(reuseIdentifier: nil, provider: { View() }, updater: updater)
	}

	/// A static, not reused view. You still get update callbacks to know when to update it.
	/// The same `view` will be used every time the menu is presented.
	///
	/// The same `view` will be used every time the menu is presented.
	/// Warning: only use the `view` in a single element: using it in multiple elements will be unpredictable.
	public static func view<View: UIView>(
		_ view: View,
		updater: @escaping (_ view: View, _ metrics: MenuMetrics, _ animated: Bool) -> Void
	) -> Self {
		return Self(reuseIdentifier: nil, provider: { view }, updater: updater)
	}

	/// A static, not reused view. You still get update callbacks to know when to update it but
	/// without the `view` parameter: you'd have to retain that yourself.
	///
	/// The same `view` will be used every time the menu is presented.
	/// Warning: only use the `view` in a single element: using it in multiple elements will be unpredictable.
	public static func view<View: UIView>(
		_ view: View,
		updater: @escaping (_ metrics: MenuMetrics, _ animated: Bool) -> Void
	) -> Self {
		return Self(reuseIdentifier: nil, provider: { view }, updater: { _, metrics, animated in
			updater(metrics, animated)
		})
	}

	/// A static, not reused view. Will be recreated when needed, most likely on every (sub)menu appearance
	/// for the element. Doesn't get update() callbacks.
	public static func viewProvider(_ provider: @escaping  () -> UIView) -> Self {
		return Self(reuseIdentifier: nil, provider: provider, updater: { _, _, _ in })
	}

	/// A static, not reused view that you don't need to reconfigure
	public static func view<View: UIView>(_ view: View) -> Self {
		return Self(reuseIdentifier: nil, provider: { view }, updater: { _, _, _ in })
	}
}
