//
//  CutOutShadowView.swift
//  Menu
//
//  Created by Andreas Verhoeven on 13/01/2025.
//

import UIKit

final class CutoutShadowView: UIImageView {
	let cornerRadius = CGFloat(13)
	let shadowSize = CGFloat(150)
	var minimumSize: CGFloat { cornerRadius + 2 }

	// MARK: - Privates
	private static var cachedImage: UIImage?

	private func createImage() -> UIImage {
		let cutoutSize = CGFloat(100)
		let side = shadowSize * 2 + cutoutSize
		let size = CGSize(width: side, height: side)
		let inset = (shadowSize + cornerRadius + 2)

		// draw a shadow behind a round rect and then cut out the round rect, so we're left with the shadow
		return UIGraphicsImageRenderer(size: size).image { context in
			let path = UIBezierPath(roundedRect: CGRect(x: shadowSize, y: shadowSize, width: cutoutSize, height: cutoutSize), cornerRadius: cornerRadius)

			// draw the round rect with shadow enabled
			context.cgContext.saveGState()
			context.cgContext.setShadow(offset: .zero, blur: shadowSize * 0.45, color: UIColor.black.cgColor)
			UIColor.black.setFill()
			path.fill()
			context.cgContext.restoreGState()

			// now cut out the round rect again by clearing it's pixels
			UIColor.black.setFill()
			path.fill(with: .clear, alpha: 1)
		}.resizableImage(withCapInsets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset), resizingMode: .stretch)
	}

	private func shadowImage() -> UIImage {
		if let cachedImage = Self.cachedImage {
			return cachedImage
		}

		let shadowImage = createImage()
		Self.cachedImage = shadowImage
		return shadowImage
	}

	// MARK: - UIView
	override func layoutSubviews() {
		super.layoutSubviews()

		guard image == nil else { return }
		image = shadowImage()
	}
}
