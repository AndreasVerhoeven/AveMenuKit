//
//  MenuElement+Internal.swift
//  Menu
//
//  Created by Andreas Verhoeven on 21/01/2025.
//

import Foundation

extension MenuElement {
	internal func changingId(to id: String) -> Self {
		self.id = id
		return self
	}
}
