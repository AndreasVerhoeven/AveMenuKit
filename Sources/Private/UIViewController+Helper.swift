//
//  UIViewController+Helper.swift
//  Demo
//
//  Created by Andreas Verhoeven on 24/01/2025.
//

import UIKit

extension UIViewController {
	var topMostPresentedViewController: UIViewController {
		return presentedViewController?.topMostPresentedViewController ?? self
	}
}
