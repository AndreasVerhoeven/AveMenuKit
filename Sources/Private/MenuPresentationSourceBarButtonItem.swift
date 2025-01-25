//
//  MenuPresentationSourceBarButtonItem.swift
//  Demo
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

internal class MenuPresentationSourceBarButtonItem: MenuPresentationSource {
	internal private(set) var barButtonItem: UIBarButtonItem?

	init(barButtonItem: UIBarButtonItem) {
		self.barButtonItem = barButtonItem
		super.init()
	}

	// MARK: - Internal
	override internal var sourceView: UIView? { barButtonItem?.value(forKey: "view") as? UIView }
	override internal var sourceRect: CGRect? { nil }
	override internal var attachmentPoint: CGPoint? { nil }
}
