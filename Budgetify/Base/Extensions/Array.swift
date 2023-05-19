//
//  Array.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 25/11/22.
//

import Foundation

extension Array where Element: (Comparable & SignedNumeric) {
    func nearest(to value: Element) -> (offset: Int, element: Element)? {
        self.enumerated().min(by: {
            abs($0.element - value) < abs($1.element - value)
        })
    }
}

