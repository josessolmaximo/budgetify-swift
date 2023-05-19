//
//  CurrencySheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 10/12/22.
//

import Foundation

class CurrencySheetViewModel: ObservableObject {
    @Published var currencies: [Currency] = Currency.allCurrencies
    @Published var searchText = ""
}

struct Currency: Hashable {
    let name: String
    let code: String
    let symbol: String?
    let identifier: String
}

extension Currency {
    static var allCurrencies: [Currency] {
//        let currencies: [Currency] = Locale.isoRegionCodes.compactMap({
//            let local = Locale(identifier: $0)
//            let locale = NSLocale(localeIdentifier: $0)
//            let currencyCode = locale.displayName(forKey: .currencyCode, value: $0)
//
//            return Currency(name: Locale(identifier: "en_US").localizedString(forIdentifier: $0) ?? "",
//                            code: local.currencyCode ?? "",
//                            symbol: locale.displayName(forKey: .currencySymbol, value: $0),
//                            identifier: locale.localeIdentifier
//            )
//        })
        let currencies: [Currency] = Locale.commonISOCurrencyCodes.compactMap {
            let name = Locale.current.localizedString(forCurrencyCode: $0) ?? ""
            var locale = NSLocale(localeIdentifier: $0)
            var id = locale.object(forKey: .countryCode) as? String ?? ""
//                if locale.displayName(forKey: .currencySymbol, value: $0) == $0 {
//                    let newlocale = NSLocale(localeIdentifier: $0.dropLast() + "_en")
//                    locale = newlocale
////                    return newlocale.displayName(forKey: .currencySymbol, value: $0)
//                }

            return Currency(name: name, code: $0, symbol: locale.displayName(forKey: .currencySymbol, value: $0), identifier: locale.localeIdentifier)
        }
//
        return currencies
    }

    func getSymbolForCurrencyCode(code: String) -> String? {
      let locale = NSLocale(localeIdentifier: code)
      return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
    }
}

class CurrencySymbol {
    static let shared: CurrencySymbol = CurrencySymbol()

    private var cache: [String:String] = [:]

    func findSymbol(currencyCode:String) -> String {
        if let hit = cache[currencyCode] { return hit }
        guard currencyCode.count < 4 else { return "" }

        let symbol = findSymbolBy(currencyCode)
        cache[currencyCode] = symbol

        return symbol
    }

    private func findSymbolBy(_ currencyCode: String) -> String {
        var candidates: [String] = []
        let locales = NSLocale.availableLocaleIdentifiers

        for localeId in locales {
            guard let symbol = findSymbolBy(localeId, currencyCode) else { continue }
            if symbol.count == 1 { return symbol }
            candidates.append(symbol)
        }

        return candidates.sorted(by: { $0.count < $1.count }).first ?? ""
    }

    private func findSymbolBy(_ localeId: String, _ currencyCode: String) -> String? {
        let locale = Locale(identifier: localeId)
        return currencyCode.caseInsensitiveCompare(locale.currencyCode ?? "") == .orderedSame
            ? locale.currencySymbol : nil
    }
}
