//
//  UIView+Cell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 21/01/2025.
//

import UIKit

extension UIView {
	static func menuHighlightingView() -> UIView {
		let highlightingView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .tertiaryFill))
		highlightingView.contentView.backgroundColor = .white
		return highlightingView
	}

	static func menuSeparatorView() -> UIView {
		let separatorView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .separator))
		separatorView.contentView.backgroundColor = .white
		// when transforming on non-pixel boundaries we don't jitter
		separatorView.contentView.layer.allowsEdgeAntialiasing = true
		separatorView.contentView.clipsToBounds = false
		return separatorView
	}
}
