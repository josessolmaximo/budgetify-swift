//
//  Int.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/02/23.
//

import Foundation

extension Int: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return self
    }
}
