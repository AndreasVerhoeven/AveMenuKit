//
//  PaletteElementLoadingCell.swift
//  Menu
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

class PaletteElementLoadingCell: UICollectionViewCell {
	let spinner = UIActivityIndicatorView(style: .medium)

	// MARK: - UIView
	override func didMoveToWindow() {
		super.didMoveToWindow()
		spinner.startAnimating()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(spinner, filling: .superview)
		spinner.startAnimating()

	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
