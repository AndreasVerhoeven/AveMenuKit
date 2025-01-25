//
//  Group.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

open class Group: MenuElement {
	public typealias Provider = () -> [MenuElement]?

	open var provider: Provider? {
		didSet {
			setNeedsUpdate()
		}
	}

	open var elements: [MenuElement] {
		return provider?() ?? []
	}

	public init(provider: Provider? = nil) {
		self.provider = provider
		super.init()
	}

	public convenience init(elements: [MenuElement]) {
		self.init(provider: { elements })
	}

	// MARK: - MenuElement
	override internal var isLeaf: Bool { false }

	override func actualMenuElements(properties: MenuProperties) -> [MenuElement] {
		return elements
	}
}
