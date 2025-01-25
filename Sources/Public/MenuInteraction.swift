//
//  MenuInteraction.swift
//  Demo
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

/// This is an interaction you can add add to any view that make a menu show up on tap and on long press.
final public class MenuInteraction: NSObject, UIInteraction {
	/// Callback that will be called to provide a menu when needed
	public var menuProvider: MenuProvider?
	public typealias MenuProvider = () -> Menu?

	/// If `menuProvider` is `nil`, this will be used as the menu
	public var menu: Menu?

	/// If set, can provide a custom `attachmentPoint` for the menu
	public var attachmentPointProvider: AttachmentPointProvider?
	public typealias AttachmentPointProvider = () -> CGPoint?

	/// The preferred element order of the menu
	public var preferredElementOrder: Menu.ElementOrder = .automatic

	/// Creates an interaction with a static menu
	public init(menu: Menu? = nil, preferredElementOrder: Menu.ElementOrder = .automatic) {
		self.menu = menu
		self.preferredElementOrder = preferredElementOrder
		super.init()
	}

	/// Creates an interaction with a menu that is provided on demand
	public init(preferredElementOrder: Menu.ElementOrder = .automatic, menuProvider: @escaping MenuProvider) {
		self.menuProvider = menuProvider
		super.init()
	}

	/// the tap gesture recognizer used
	public private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))

	/// the long press gesture recognizer used
	public private(set) lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))


	/// presents the menu if we have one
	public func presentMenu(animated: Bool) {
		guard let view else { return }

		updateMenuIfNeeded()
		guard let menu else { return }
		guard presentation == nil else { return }

		presentation = MenuPresentation.presentMenu(menu, source: .view(view, attachmentPointProvider: attachmentPointProvider), preferredElementOrder: preferredElementOrder, animated: animated, dismissal: { [weak self] in
			guard let self else { return }
			presentation = nil
			if menuProvider != nil {
				self.menu = nil
			}
		})
	}

	/// dismisses any active menu
	public func dismissMenu(animated: Bool) {
		presentation?.dismiss(animated: animated)
	}

	// MARK: MenuInteraction
	public private(set) weak var view: UIView?

	public func willMove(to view: UIView?) {
	}

	public func didMove(to view: UIView?) {
		if let oldView = self.view {
			oldView.removeGestureRecognizer(tapGestureRecognizer)
			oldView.removeGestureRecognizer(longPressGestureRecognizer)

		}

		self.view = view
		if let view {
			view.addGestureRecognizer(tapGestureRecognizer)
			view.addGestureRecognizer(longPressGestureRecognizer)
		}
	}

	// MARK: - Input
	@objc private func tapped(_ sender: Any) {
		presentMenu(animated: true)
	}

	@objc private func longPressed(_ sender: Any) {
		if longPressGestureRecognizer.state == .began && presentation == nil {
			presentMenu(animated: true)
			presentation?.transferringLongPressGestureRecognizer = longPressGestureRecognizer
		}
	}

	// MARK: - Privates
	private var presentation: MenuPresentation?

	private func updateMenuIfNeeded() {
		if let menuProvider {
			menu = menuProvider()
		}
	}
}
