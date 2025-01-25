//
//  MenuLeaf.swift
//  Menu
//
//  Created by Andreas Verhoeven on 20/01/2025.
//

import UIKit

/// Marker protocol
public protocol NonSelectableMenuLeaf {
}


public protocol MenuStandardContent {
	var title: String? { get set }
	var subtitle: String? { get set }
	var image: UIImage? { get set }
}

public protocol StateHaveableMenuLeaf {
	var isEnabled: Bool { get }
	var isDestructive: Bool { get }
}

extension StateHaveableMenuLeaf {
	var mainContentColor: UIColor {
		if isEnabled == false {
			return .secondaryLabel
		} else if isDestructive == true {
			return .systemRed
		} else {
			return .label
		}
	}
}

public protocol MenuLeaf: StateHaveableMenuLeaf {
	var isEnabled: Bool { get set }
	var isDestructive: Bool { get set }
}

public protocol MenuActionLeaf: MenuLeaf {
	var keepsMenuPresented: Bool { get set }
	var handler: ((Self) -> Void)? { get set }
}

public protocol SelectableMenuActionLeaf: MenuActionLeaf {
	var isSelected: Bool { get set }
}

public protocol MenuStandardContentLeaf: MenuLeaf, MenuStandardContent {
}
