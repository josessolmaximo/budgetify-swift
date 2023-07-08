//
//  LoginView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 01/10/22.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseAnalyticsSwift

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var vm: LoginViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @State var selectedPage = 0
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Spacer()
                
                title
                
//                subtitle
                
//                featureList
                
                Spacer()
                
                loginButtons
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LoginViewModel(loginService: MockLoginService()))
            .environmentObject(ThemeManager())
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            .previewDisplayName("iPhone 8")
        
        LoginView()
            .environmentObject(LoginViewModel(loginService: MockLoginService()))
            .environmentObject(ThemeManager())
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
    }
}

extension LoginView {
    var title: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Hello, ")
                    .font(.largeTitle.weight(.bold)) +
                Text("Welcome to ")
                    .font(.largeTitle.weight(.bold)) +
                Text("Budgetify")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(tm.selectedTheme.tintColor)
            }
            
            Spacer()
        }
    }
    
    var subtitle: some View {
        HStack {
            Text("Track, manage, and analyze your expenses with our features.")
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .font(.title3.weight(.medium))
                .foregroundColor(tm.selectedTheme.secondaryLabel)
            
            Spacer()
        }
        .padding(.bottom, 10)
    }
    
    var featureList: some View {
        ForEach([
            "Add Multiple Transactions at Once",
            "Schedule Recurring Transactions",
            "Create and Monitor Budgets",
            "Add Debit, Credit and Goal Wallets",
            "65 Default Categories",
            "Clear and Simple Reports",
            "Dark Mode",
            "No Ads"
        ], id: \.self) { text in
            HStack {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                
                Text(text)
                    .fontWeight(.medium)
//                    .lineLimit(1)
//                    .minimumScaleFactor(0.5)
                Spacer()
            }
        }
    }
    
    var loginButtons: some View {
        VStack(spacing: 5) {
            SignInWithAppleButton(.signIn) { request in
                vm.nonce = vm.randomNonceString()
                request.requestedScopes = [.email, .fullName]
                request.nonce = vm.sha256(vm.nonce)
            } onCompletion: { result in
                switch result {
                case .success(let user):
                    guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                        return
                    }
                    
                    Task {
                        await vm.handleAppleLogin(credential: credential)
                    }
                case .failure(let error):
                    Logger.e(error.localizedDescription)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 40, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            HStack {
                Rectangle()
                
                    .frame(height: 1)
                
                Text("or")
                    .foregroundColor(Color("#929292"))
                    .font(.subheadline)
                Rectangle()
                    .frame(height: 1)
            }
            .foregroundColor(tm.selectedTheme.tertiaryLabel)
            
            Button(action: {
                vm.handleGoogleLogin(viewController: getRootViewController())
            }, label: {
                HStack {
                    Image("icon_google")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("Sign in with Google")
                        .font(.system(size: 15))
                        .foregroundColor(tm.selectedTheme.primaryLabel)
                }
                .frame(height: 35)
                .frame(maxWidth: .infinity)
            })
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tm.selectedTheme.primaryLabel.opacity(0.5))
            )
            
        }
    }
}
