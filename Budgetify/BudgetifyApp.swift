//
//  BudgetifyApp.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 01/10/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FirebaseFirestore
import FirebaseRemoteConfig
import FirebaseAnalytics
import FirebaseAuth
import RevenueCat
import LogRocket
import Bugsnag
import Mixpanel

@main
struct BudgetifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var tm = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tm)
                .defaultAppStorage(.grouped)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        #if DEBUG && targetEnvironment(simulator)
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(ProductionAppCheckProviderFactory())
        #endif
        
        FirebaseApp.configure()
        
        Purchases.logLevel = .debug
        Purchases.configure(with: Configuration.Builder(withAPIKey: "appl_oTslfZGPFUBZwsHvGRpPZZufUGM")
            .with(usesStoreKit2IfAvailable: false)
            .build()
        )
        
        if let instanceID = Analytics.appInstanceID() {
            Purchases.shared.attribution.setFirebaseAppInstanceID(instanceID)
        }
        
        let _ = ConfigManager.shared
        
        SDK.initialize(configuration: Configuration(appID: "xj2fdl/budgetify"))
        
        Bugsnag.start()
        
        Mixpanel.initialize(token: "bdda7fd61a5b8891a86ae99ce3a242b1", trackAutomaticEvents: true)
        
        return true
    }
}

class ProductionAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}


