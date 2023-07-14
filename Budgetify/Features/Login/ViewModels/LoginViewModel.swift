//
//  LoginViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 01/10/22.
//

import SwiftUI
import WidgetKit

import CryptoKit

import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

import FirebaseAuth
import FirebaseCore

import RevenueCat
import Mixpanel

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var nonce = ""
    
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String?
    @AppStorage("selectedEmail", store: .grouped) var selectedEmail: String?
    @AppStorage("selectedName", store: .grouped) var selectedName: String?
    @AppStorage("selectedPhotoURL", store: .grouped) var selectedPhotoURL: URL?
    
    @AppStorage("userId", store: .grouped) var userId: String?
    @AppStorage("email", store: .grouped) var email: String?
    @AppStorage("name", store: .grouped) var name: String?
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    
    let loginService: LoginServiceProtocol
    
    init(loginService: LoginServiceProtocol){
        self.loginService = loginService
    }
    
    func handleAppleLogin(credential: ASAuthorizationAppleIDCredential) async {
        guard let token = credential.identityToken else {
            return
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            
            await setupUser(user: result.user)
        } catch {
            ErrorManager.shared.logError(error: error.firestoreError, vm: self)
        }
    }
    
    func handleGoogleLogin(viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                Logger.e(error.localizedDescription)
                return
            }
            
            guard let result = result,
                  let idToken = result.user.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: result.user.accessToken.tokenString)
            
            Task {
                ErrorManager.shared.logRequest(vm: self)

                do {
                    let result = try await Auth.auth().signIn(with: credential)

                    await self.setupUser(user: result.user)
                } catch {
                    ErrorManager.shared.logError(error: error.firestoreError, vm: self)
                }
            }
        }
    }
    
    func setupUser(user: FirebaseAuth.User) async {
        self.userId = user.uid
        self.email = user.email
        self.name = user.displayName
        self.photoURL = user.photoURL
        
        self.selectedUserId = user.uid
        self.selectedEmail = user.email
        self.selectedName = user.displayName
        self.selectedPhotoURL = user.photoURL
        
        ErrorManager.shared.logRequest(vm: self)
 
        WidgetCenter.shared.reloadAllTimelines()
        
        do {
            try await loginService.checkIfUserExists(id: user.uid)
            
            let result = try await Purchases.shared.logIn(user.uid)
            
            PremiumManager.shared.isPremium = result.customerInfo.entitlements["premium"]?.isActive ?? false
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        Purchases.shared.attribution.setEmail(user.email)
        Purchases.shared.attribution.setDisplayName(user.displayName)
        
        Mixpanel.mainInstance().identify(distinctId: user.uid)
        Mixpanel.mainInstance().people.set(properties: [
            "$name": user.displayName ?? "",
            "$email": user.email ?? "",
            "$avatar": user.photoURL?.absoluteString ?? "",
        ])
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}


