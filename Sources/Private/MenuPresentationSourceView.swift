//
//  MenuPresentationSourceView.swift
//  Demo
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

internal class MenuPresentationSourceView: MenuPresentationSource {
	internal private(set) weak var view: UIView?
	internal var rect: CGRect?

	internal var attachmentPointProvider: AttachmentPointProvider?

	public init(view: UIView, rect: CGRect? = nil, attachmentPointProvider: AttachmentPointProvider? = nil) {
		self.view = view
		self.rect = rect
		self.attachmentPointProvider = attachmentPointProvider
		super.init()
	}

	internal convenience init(view: UIView, rect: CGRect? = nil, attachmentPoint: CGPoint) {
		self.init(view: view, rect: rect, attachmentPointProvider: { attachmentPoint })
	}

	// MARK: - MenuPresentationSource
	override internal var sourceView: UIView? { view }
	override internal var sourceRect: CGRect? { rect }
	override internal var attachmentPoint: CGPoint? { attachmentPointProvider?() }
}
