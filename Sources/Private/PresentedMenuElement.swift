//
//  PresentedMenuElement.swift
//  Menu
//
//  Created by Andreas Verhoeven on 16/01/2025.
//

import UIKit

/// A presented menu element: element with presentation flags
class PresentedMenuElement: Identifiable {
	// the element being presented
	var element: MenuElement

	var id: String { element.id }

	init(element: MenuElement) {
		self.element = element
	}

	/// if we should show a separator
	internal var shouldShowSeparator = true

	/// if the menu has a leading accessory - used to inset action rows
	internal var menuHasLeadingAccessory = false
}
