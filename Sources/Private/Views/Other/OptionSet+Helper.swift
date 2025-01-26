//
//  OptionSet+Helper.swift
//  Demo
//
//  Created by Andreas Verhoeven on 26/01/2025.
//

import Foundation

extension OptionSet {
	mutating func toggle(_ element: Element, on: Bool) {
		if on == true {
			insert(element)
		} else {
			remove(element)
		}
	}
}
