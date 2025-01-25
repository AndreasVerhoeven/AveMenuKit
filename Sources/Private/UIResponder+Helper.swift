//
//  UIResponder+Helper.swift
//  Demo
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

extension UIResponder {
	var closestViewController: UIViewController? {
		var responder = next
		while let current = responder, (current is UIViewController) == false {
			responder = current.next
		}
		return responder as? UIViewController
	}
}
