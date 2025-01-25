//
//  Menu+Internal.swift
//  Menu
//
//  Created by Andreas Verhoeven on 21/01/2025.
//

import UIKit

extension Menu.ElementSize {
	var maximumOfElementsPerRow: Int {
		switch self {
			case .small: return 3
			case .medium: return 5
			case .large: return -1
			case .automatic: return -1
		}
	}
}

extension Menu {
	internal func actualElementSize(properties: MenuProperties) -> Menu.ElementSize {
		guard properties.isInAccessibilityMode == false else { return .large }
		return preferredElementSize == .automatic ? .large : preferredElementSize
	}

	internal func headerLeafs(properties: MenuProperties) -> [MenuElement] {
		return leafs(from: headers, hasMenuHeader: true, properties: properties)
	}

	internal func childrenLeafs(hasMenuHeader: Bool, properties: MenuProperties) -> [MenuElement] {
		return leafs(from: children, hasMenuHeader: hasMenuHeader, properties: properties)
	}

	internal func leafs(from elements: [MenuElement], hasMenuHeader: Bool, properties: MenuProperties) -> [MenuElement] {
		class Group {
			var owner: Menu
			var leafs = [MenuElement]()
			
			init(owner: Menu, leafs: [MenuElement] = [MenuElement]()) {
				self.owner = owner
				self.leafs = leafs
			}
		}
		
		var groups = [Group]()
		var ownerStack = [self]
		
		func addLeaf(_ leaf: MenuElement) {
			guard let currentOwner = ownerStack.last else { return }
			if groups.last?.owner.id == currentOwner.id {
				groups.last?.leafs.append(leaf)
			} else {
				groups.append(Group(owner: currentOwner, leafs: [leaf]))
			}
		}
		
		func addLeafGroups(for elements: [MenuElement]) {
			for element in elements where element.isHidden == false {
				var addedToOwnerStack = false
				if let menu = element as? Menu, menu.displaysInline == true {
					addedToOwnerStack = true
					ownerStack.append(menu)
				}

				delegate?.registerElement(element)

				if element.isLeaf == true {
					addLeaf(element)
				} else {
					let subElements = element.actualMenuElements(properties: properties).filter { $0 !== element }
					addLeafGroups(for: subElements)
				}
				
				if addedToOwnerStack {
					ownerStack.removeLast()
				}
			}
		}

		addLeafGroups(for: elements)

		if displaysAsPalette == true {
			var paletteCounter = 0
			for group in groups where group.owner === self {
				group.leafs = [ inlinePalette(index: paletteCounter, elements: group.leafs) ]
				paletteCounter += 1
			}
		} else {
			var buttonsCounter = 0
			for group in groups where group.owner === self {
				let size = actualElementSize(properties: properties)
				let maximumNumberOfElements = size.maximumOfElementsPerRow
				if maximumNumberOfElements > 0 {
					let split = min(group.leafs.count, maximumNumberOfElements)
					let groupElement = inlineGroup(index: buttonsCounter, elements: Array(group.leafs[..<split]), size: size)
					group.leafs = [groupElement] + group.leafs[split...]
					buttonsCounter += 1
				}
			}
		}
		
		var finalLeafs = [MenuElement]()
		var currentMenu: Menu?
		
		if hasMenuHeader == false, let title, title.isEmpty == false, groups.isEmpty == false {
			let titleHeaderElement = titleHeader(for: id, title: title)
			finalLeafs.append(titleHeaderElement)
			currentMenu = self
		}


		// we now have groups, lets iterate over these groups
		for group in groups {
			var newCurrentMenu = group.owner
			if betweenMenusSeparatorStyle == .automatic {
				if group.owner !== currentMenu && finalLeafs.isEmpty == false {
					if group.owner.displaysAsPalette == true {
						newCurrentMenu = self
					} else  if group.owner.betweenMenusSeparatorStyle == .automatic && (currentMenu?.betweenMenusSeparatorStyle ?? .automatic) == .automatic {
						let separatorElement = separator(from: currentMenu?.id, to: group.owner.id)
						finalLeafs.append(separatorElement)
					}
				}
			}

			finalLeafs += group.leafs
			currentMenu = newCurrentMenu
		}
		
		return finalLeafs
	}

	// MARK: - Privates
	internal func subMenuElement() -> SubMenuElement {
		return subElement(for: idForSubMenuElement, creation: { SubMenuElement(menu: self) })
	}

	private func inlinePalette(index: Int, elements: [MenuElement]) -> InlinePalette {
		let paletteId = "Palette #\(index + 1) for menu \(id)"
		let paletteElement = subElement(for: paletteId, creation: { InlinePalette(elements: elements) })
		paletteElement.ignoringUpdates {
			paletteElement.elements = elements
			paletteElement.selectionStyle = paletteSelectionStyle
		}
		return paletteElement
	}

	private func inlineGroup(index: Int, elements: [MenuElement], size: Menu.ElementSize) -> InlineGroup {
		let inlineElementId = "InlineGroup Buttons #\(index + 1) for menu \(id)"
		let groupElement = subElement(for: inlineElementId, creation: { InlineGroup(size: size, elements: elements) })
		groupElement.ignoringUpdates {
			groupElement.size = size
			groupElement.elements = elements
		}
		return groupElement
	}

	private func separator(from: ID?, to: ID) -> Separator {
		let separatorId = "Separator from \(from ?? "") to \(to)"
		return subElement(for: separatorId, creation: { Separator() })
	}

	private func titleHeader(for id: ID, title: String) -> TitleHeader {
		let titleId = "Title for menu \(id)"
		let titleHeader = subElement(for: titleId, creation: { TitleHeader(title) })
		titleHeader.ignoringUpdates {
			titleHeader.title = title
		}
		return titleHeader
	}
}
