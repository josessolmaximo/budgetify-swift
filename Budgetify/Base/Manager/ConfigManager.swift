//
//  ConfigManager.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 13/02/23.
//

import Foundation
import FirebaseRemoteConfig

class ConfigManager {
    static let shared = ConfigManager()

    private var rc: RemoteConfig
    
    public var paywallLimits: [String: Int] {
        rc.configValue(forKey: Config.paywallLimits.rawValue).jsonValue as? [String: Int] ?? [:]
    }
    
    public var transactionRatingLimit: Int {
        rc.configValue(forKey: Config.transactionRatingLimit.rawValue).numberValue as? Int ?? 20
    }
    
    public var privacyPolicyLink: String {
        rc.configValue(forKey: Config.privacyPolicyLink.rawValue).stringValue ?? ""
    }
    
    public var termsOfUseLink: String {
        rc.configValue(forKey: Config.termsOfUseLink.rawValue).stringValue ?? ""
    }
    
    public var developerWebsiteLink: String {
        rc.configValue(forKey: Config.developerWebsiteLink.rawValue).stringValue ?? ""
    }
    
    public var minimumVersion: String {
        rc.configValue(forKey: Config.minimumVersion.rawValue).stringValue ?? "1.0.0"
    }
    
    public var contactEmail: String {
        rc.configValue(forKey: Config.contactEmail.rawValue).stringValue ?? "contact.budgetify@gmail.com"
    }
    
    public var onboarding: OnboardingConfig {
        let json = rc.configValue(forKey: Config.onboarding.rawValue).jsonValue as? [String: Bool] ?? [:]
        
        return OnboardingConfig(
            showOnboarding: json["showOnboarding"] ?? true,
            showPaywall: json["showPaywall"] ?? true,
            requestRating: json["requestRating"] ?? true)
    }
    
    struct OnboardingConfig {
        var showOnboarding: Bool
        var showPaywall: Bool
        var requestRating: Bool
    }
    
    init(){
        let rc = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        
        settings.minimumFetchInterval = 0
        rc.configSettings = settings
        rc.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        self.rc = rc
        
        Task {
            try await rc.fetchAndActivate()
            
            checkMinimumVersion(current: Bundle.main.releaseVersionNumber, minimum: minimumVersion)
        }
    }
    
    func checkMinimumVersion(current: String, minimum: String){
        DispatchQueue.main.async {
            ErrorManager.shared.versionError = current.isVersion(lessThan: minimum)
        }
    }
}

enum Config: String {
    case budgetsLimit = "budgets_limit"
    case multipleTransactionsLimit = "multiple_transactions_limit"
    case walletsLimit = "wallets_limit"
    case subcategoriesLimit = "subcategories_limit"
    case transactionRatingLimit = "transaction_rating_limit"
    case paywallLimits = "paywall_limits"
    case privacyPolicyLink = "privacy_policy_link"
    case termsOfUseLink = "terms_of_use_link"
    case developerWebsiteLink = "developer_website_link"
    case minimumVersion = "minimum_version"
    case contactEmail = "contact_email"
    case onboarding = "onboarding"
}
