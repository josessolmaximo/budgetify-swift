//
//  Result.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 21/12/22.
//

import Foundation

extension Result {
    var mapped: Result<Any, ServiceError> {
        return self.map({$0 as Any}).mapError({$0 as! ServiceError})
    }
}
