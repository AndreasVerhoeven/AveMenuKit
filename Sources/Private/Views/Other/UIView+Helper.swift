//
//  UIView+Helper.swift
//  Menu
//
//  Created by Andreas Verhoeven on 14/01/2025.
//

import UIKit

extension UIView {
	var frameIgnoringTransform: CGRect {
		get {
			return CGRect(
				x: center.x - bounds.width * layer.anchorPoint.x,
				y: center.y - bounds.height * layer.anchorPoint.y,
				width: bounds.width,
				height: bounds.height
			)
		}
		set(frame) {
			bounds = CGRect(x: bounds.minX, y: bounds.minY, width: frame.width, height: frame.height)
			center = CGPoint(x: frame.minX + frame.width * layer.anchorPoint.x, y: frame.minY + frame.height * layer.anchorPoint.y)
		}
	}

	func setFrameIgnoringTransform(_ frame: CGRect, anchorPoint: CGPoint) {
		layer.anchorPoint = anchorPoint
		frameIgnoringTransform = frame
	}
}
