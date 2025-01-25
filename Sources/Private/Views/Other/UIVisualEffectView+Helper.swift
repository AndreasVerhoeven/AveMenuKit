//
//  UIVisualEffectView+Helper.swift
//  Menu
//
//  Created by Andreas Verhoeven on 16/01/2025.
//

import UIKit

extension UIVisualEffectView {
	static let blurEffectPresentationValueKey = "**g**r*o**u*pN**a***m****e".replacingOccurrences(of: "*", with: "")

	var presentationIdentifier: String? {
		get { nil }
		set {
			layer.sublayers?.first?.setValue(newValue, forKey: Self.blurEffectPresentationValueKey)
		}
	}
}
