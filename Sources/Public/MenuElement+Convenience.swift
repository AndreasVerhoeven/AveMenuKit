//
//  MenuElement+Convenience.swift
//  Menu
//
//  Created by Andreas Verhoeven on 23/01/2025.
//

import UIKit

public extension MenuElement {
	static func inline(_ elements: [MenuElement]) -> Menu {
		return Menu(displaysInline: true, children: elements)
	}

	static func inline(_ elements: MenuElement...) -> Menu {
		return inline(elements)
	}

	static func menu(title: String = "", image: UIImage? = nil, _ children: [MenuElement], headers: [MenuElement] = []) -> Menu {
		return Menu(title: title, image: image, children: children, headers: headers)
	}

	static func submenu(title: String, image: UIImage? = nil, _ children: [MenuElement], headers: [MenuElement] = []) -> Menu {
		return Menu(title: title, image: image, children: children, headers: headers)
	}

	static func submenu(title: String, image: UIImage? = nil, _ children: MenuElement...) -> Menu {
		return Menu(title: title, image: image, children: children)
	}

	static var separator: Separator {
		return Separator()
	}

	static func customView(_ view: ReusableViewConfiguration) -> CustomView {
		return CustomView(view: view)
	}

	static func customView(_ view: UIView) -> CustomView {
		return CustomView(view: .view(view))
	}

	static func customView(_ viewProvider: @escaping () -> UIView) -> CustomView {
		return CustomView(view: .viewProvider(viewProvider))
	}
}

public extension MenuElement {
	static func mediumInlineGroup(_ element1: MenuElement, _ element2: MenuElement? = nil, _ element3: MenuElement? = nil) -> Menu {
		let elements = [element1, element2, element3].compactMap { $0 }
		return mediumInlineGroup(elements)
	}

	static func mediumInlineGroup(_ elements: [MenuElement]) -> Menu {
		return Menu(preferredElementSize: .medium, displaysInline: true, betweenMenusSeparatorStyle: .none, children: elements)
	}
}

public extension MenuElement {
	static func smallInlineGroup(_ element1: MenuElement, _ element2: MenuElement? = nil, _ element3: MenuElement? = nil, _ element4: MenuElement? = nil, _ element5: MenuElement? = nil ) -> Menu {
		let elements = [element1, element2, element3, element4, element5].compactMap { $0 }
		return smallInlineGroup(elements)
	}

	static func smallInlineGroup(_ elements: [MenuElement]) -> Menu {
		return Menu(preferredElementSize: .small, displaysInline: true, betweenMenusSeparatorStyle: .none, children: elements)
	}
}

public extension MenuElement {
	static func palette(_ elements: MenuElement...) -> Menu {
		return palette(elements)
	}
	static func palette(_ elements: [MenuElement]) -> Menu {
		return Menu(displaysInline: true, displaysAsPalette: true, children: elements)
	}
}

public extension MenuElement {
	static func cachedLazy(_ provider: @escaping LazyMenuElement.Provider) -> LazyMenuElement {
		return LazyMenuElement(shouldCache: true, provider: provider)
	}

	static func uncachedLazy(_ provider: @escaping LazyMenuElement.Provider) -> LazyMenuElement {
		return LazyMenuElement(shouldCache: false, provider: provider)
	}
}
