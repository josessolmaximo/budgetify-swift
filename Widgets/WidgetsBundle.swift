//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Joses Solmaximo on 17/04/23.
//

import SwiftUI
import WidgetKit
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck

@main
struct WidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TransactionWidget()
        BudgetWidget()
        LimitedReportWidget()
        ReportWidget()
        ShortcutWidget()
    }
}

class ProductionAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}
