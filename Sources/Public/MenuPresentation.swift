//
//  MenuPresentation.swift
//  Menu
//
//  Created by Andreas Verhoeven on 14/01/2025.
//

import UIKit

/// This manages the presentation of a menu
final public class MenuPresentation {
	/// The menu to present, must be set before calling `present()`. Changing it
	/// while a presentation is in progress does nothing.
	public var menu: Menu?

	/// The source from where we present. Must be set before calling `present()`.
	/// Must be part of a `UIViewController` hierarchy.
	public var source: MenuPresentationSource?

	/// The element order we want the menu elements to be in
	public var preferredElementOrder: Menu.ElementOrder = .automatic

	/// Set this if you want to presented a menu from a `UILongPressGestureRecognizer` and you want the gesture
	/// to be transferred to the menu
	public weak var transferringLongPressGestureRecognizer: UILongPressGestureRecognizer? {
		didSet {
			guard let transferringLongPressGestureRecognizer else { return }
			overlayViewController?.menuView.transferLongPressGestureRecognizer(transferringLongPressGestureRecognizer)
		}
	}

	/// called when the menu has been dismissed
	public var dismissalCallback: DismissalCallback?
	public typealias DismissalCallback = () -> Void

	/// Presents a `menu` from a given `source`
	@discardableResult public static func presentMenu(
		_ menu: Menu,
		source: MenuPresentationSource,
		preferredElementOrder: Menu.ElementOrder = .automatic,
		animated: Bool,
		dismissal: DismissalCallback? = nil
	) -> MenuPresentation {
		let presentation = MenuPresentation()
		presentation.menu = menu
		presentation.source = source
		presentation.preferredElementOrder = preferredElementOrder
		presentation.dismissalCallback = dismissal
		presentation.present(animated: animated)
		return presentation
	}

	/// Presents the `menu`. Both `menu` and `source` must be set - not setting them is an error.
	/// Does nothing if a menu is already presented.
	public func present(animated: Bool) {
		guard overlayViewController == nil else { return }

		guard let source, let sourceView = source.sourceView else {
			assert(source?.sourceView != nil, "Needs to have a source view before we can be presented")
			dismissalCallback?()
			return
		}

		guard let hostingViewController = sourceView.closestViewController?.topMostPresentedViewController else {
			assert(false, "sourceView needs to be part of a View Controller hierarchy")
			dismissalCallback?()
			return
		}

		let sourceRect = source.sourceRect
		let menuAttachmentPoint = source.attachmentPoint ?? MenuPresentationSource.defaultMenuAttachmentPoint(for: sourceView, sourceRect: sourceRect)

		let overlayViewController = MenuViewOverlayViewController()
		overlayViewController.presentation = self
		overlayViewController.menuView.menuAttachmentPoint = menuAttachmentPoint
		overlayViewController.menuView.sourceView = sourceView
		overlayViewController.menuView.sourceRect = sourceRect
		overlayViewController.menuView.preferredElementOrder = preferredElementOrder
		overlayViewController.menuView.menu = menu

		if let transferringLongPressGestureRecognizer {
			overlayViewController.menuView.transferLongPressGestureRecognizer(transferringLongPressGestureRecognizer)
		}
		
		overlayViewController.modalPresentationStyle = .overFullScreen
		overlayViewController.transitioningDelegate = overlayViewController
		overlayViewController.menuView.dismissalCallback = { [weak self] in
			guard let self else { return }
			self.overlayViewController = nil
			self.dismissalCallback?()
		}
		self.overlayViewController = overlayViewController
		hostingViewController.present(overlayViewController, animated: false)
	}

	/// Dismisses the current presentation.
	public func dismiss(animated: Bool) {
		overlayViewController?.dismiss(animated: true)
	}
	
	// MARK: - Privates
	private var overlayViewController: MenuViewOverlayViewController?
}
