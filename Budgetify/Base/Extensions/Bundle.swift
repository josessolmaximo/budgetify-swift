//
//  Bundle.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 22/12/22.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }
}
