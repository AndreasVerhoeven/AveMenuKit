//
//  LoadingElement.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import Foundation

public class LoadingElement: MenuElement {

	public init(for element: MenuElement? = nil) {
		super.init()

		if let element {
			id = "Loading for \(element.id)"
		}
	}

	// MARK: - MenuElement
	override internal var isLeaf: Bool { true }
	override var elementTableViewCellClass: MenuBaseCell.Type { MenuLoadingCell.self }
}
