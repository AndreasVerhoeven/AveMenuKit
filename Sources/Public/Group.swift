//
//  Group.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// Logically groups elements together. You can use this for subclassing
open class Group: MenuElement {
	/// Subclasses should return the elements they want to display here
	open var displayedElements: [MenuElement] {
		return assignedElements ?? []
	}

	/// the elements passed in this init are by default returned in `elements`
	public init(elements: [MenuElement]? = nil) {
		assignedElements = elements
		super.init()
	}

	// MARK: - MenuElement
	override internal var isLeaf: Bool { false }

	override func actualMenuElements(properties: MenuProperties) -> [MenuElement] {
		return displayedElements
	}

	// MARK: - Privates
	private var assignedElements: [MenuElement]?
}
