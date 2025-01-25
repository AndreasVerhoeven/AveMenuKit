//
//  MenuItemDelegate.swift
//  Menu
//
//  Created by Andreas Verhoeven on 14/01/2025.
//

import UIKit

internal protocol MenuElementDelegate: AnyObject {
	func setNeedsUpdate()
	func updateImmediately()
	func toggleSubMenu(_ subMenu: Menu)
	func registerElement(_ element: MenuElement)
	func registerScrollView(_ scrollView: UIScrollView)
}
