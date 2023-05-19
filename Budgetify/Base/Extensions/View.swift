//
//  View.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 19/12/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
    var pageTitle: String {
        return String(String(reflecting: type(of: self)).split(separator: ".").last ?? "Unknown Page")
    }
}

extension View {
    func errorAlert<E: LocalizedError>(error: Binding<E?>) -> some View {
        return alert(isPresented: .constant(error.wrappedValue != nil), error: error.wrappedValue) { _ in
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "Try again")
        }
    }
}
