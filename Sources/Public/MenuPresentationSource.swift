//
//  MenuPresentationSource.swift
//  Demo
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

/// This abstracts away the difference between presenting from a view and a bar button item
open class MenuPresentationSource {
	public typealias AttachmentPointProvider = () -> CGPoint?
	
	/// Present from a view.
	/// - `rect` is optionally the rectangle in `view` coordinates. If `nil`, the `view`s bounds will be used
	/// - `attachmentPointProvider` is an optional callback to provide the point __inside__ `view` where the menu attaches to
	public static func view(_ view: UIView, rect: CGRect? = nil, attachmentPointProvider: AttachmentPointProvider? = nil) -> MenuPresentationSource {
		return MenuPresentationSourceView(view: view, rect: rect, attachmentPointProvider: attachmentPointProvider)
	}

	/// Present from a view.
	/// - `rect` is optionally the rectangle in `view` coordinates. If `nil`, the `view`s bounds will be used
	/// - `attachmentPoint` is an optional  point __inside__ `view` where the menu attaches to
	public static func view(_ view: UIView, rect: CGRect? = nil, attachmentPoint: CGPoint) -> MenuPresentationSource {
		return MenuPresentationSourceView(view: view, rect: rect, attachmentPoint: attachmentPoint)
	}

	/// Presents from a `UIBarButtonItem`
	public static func barButtonItem(_ barButtonItem: UIBarButtonItem) -> MenuPresentationSource {
		return MenuPresentationSourceBarButtonItem(barButtonItem: barButtonItem)
	}

	/// The default implementation for getting a menu attachment point. `sourceRect` is in `sourceView` coordinates - if `nil`
	/// the `view`s bounds will be used.
	public static func defaultMenuAttachmentPoint(for sourceView: UIView, sourceRect: CGRect? = nil) -> CGPoint {
		let rectInSourceView = sourceRect ?? sourceView.bounds
		if let window = sourceView.window {
			let rectInScreenCoordinates = sourceView.convert(rectInSourceView, to: window)
			if rectInScreenCoordinates.midY > window.bounds.height * 0.5 {
				return CGPoint(x: rectInSourceView.midX, y: rectInSourceView.minY - 4)
			} else {
				return CGPoint(x: rectInSourceView.midX, y: rectInSourceView.maxY + 4)
			}
		} else {
			return CGPoint(x: rectInSourceView.midX, y: rectInSourceView.midY)
		}
	}

	// MARK: - Internal
	internal var sourceView: UIView? { nil }
	internal var sourceRect: CGRect? { nil }
	internal var attachmentPoint: CGPoint? { nil }
}
