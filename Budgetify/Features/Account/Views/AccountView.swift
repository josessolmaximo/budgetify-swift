//
//  AccountView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 22/10/22.
//

import SwiftUI
import MessageUI
import FirebaseAnalyticsSwift

struct AccountView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("userId", store: .grouped) var userId: String?
    @AppStorage("email", store: .grouped) var email: String?
    @AppStorage("name", store: .grouped) var name: String?
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String?
    @AppStorage("selectedEmail", store: .grouped) var selectedEmail: String?
    @AppStorage("selectedName", store: .grouped) var selectedName: String?
    @AppStorage("selectedPhotoURL", store: .grouped) var selectedPhotoURL: URL?
    
    @EnvironmentObject var vm: AccountViewModel
    @EnvironmentObject var tm: ThemeManager
    @EnvironmentObject var sharingVM: SharingViewModel
    
    @StateObject var em = ErrorManager.shared
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        switcherSection
                        
                        sharedSection
                        
                        settingSection
                        
                        contactSection
                        
                        logoutSection
                        
                        versionSection
                        
                        Spacer()
                    }
                }
                .refreshable {
                    Task {
                        await sharingVM.getAccess()
                    }
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(CustomBackButtonModifier(dismiss: dismiss))
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .sheet(isPresented: $em.premiumError) {
            PremiumSheetView(lastScreen: self.pageTitle)
        }
    }
}

extension AccountView {
    func accountRow(id: String, name: String, email: String, photoURL: URL?) -> some View {
        return HStack {
            ProfilePictureView(photoURL: photoURL, dimensions: 30)
            
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Text(name)
                        .fontWeight(.medium)
                }
                
                Text(email)
                    .font(.subheadline)
                    .tint(tm.selectedTheme.primaryLabel)
            }
            .padding(.leading, 5)
            
            Spacer()
        }
        .frame(height: 40)
        .padding(.horizontal, 10)
        .padding(.vertical, 12.5)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tm.selectedTheme.tertiaryLabel, lineWidth: 2)
                .padding(.vertical, 5)
                .opacity(id == selectedUserId ? 1 : 0)
        )
    }
    
    var versionSection: some View {
        HStack {
            Spacer()
            Text("v\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                .font(.system(size: 13, weight: .semibold))
            Spacer()
        }
        .padding(.top, 10)
    }
    
    var switcherSection: some View {
        VStack(spacing: 0) {
            accountRow(id: userId ?? "", name: name ?? "Anonymous User", email: email ?? "Unknown Email", photoURL: photoURL)
                .onTapGesture {
                    Task {
                        guard let userId = userId else { return }
                        
                        vm.isSwitcherLoading = true
                        
                        await PremiumManager.shared.getPremium(id: userId)
                        
                        vm.isSwitcherLoading = false
                        
                        self.selectedUserId = userId
                        self.selectedEmail = email
                        self.selectedName = name
                        self.selectedPhotoURL = photoURL
                    }
                }
            
            ForEach(sharingVM.access, id: \.self){ access in
                Divider()
                
                accountRow(id: access.originUser.id, name: access.originUser.displayName, email: access.originUser.email, photoURL: URL(string: access.originUser.photoURL))
                .onTapGesture {
                    Task {
                        vm.isSwitcherLoading = true
                        
                        await PremiumManager.shared.getPremium(id: access.originUser.id)
                        
                        vm.isSwitcherLoading = false
                        
                        if PremiumManager.shared.isPremium {
                            self.selectedUserId = access.originUser.id
                            self.selectedEmail = access.originUser.email
                            self.selectedName = access.originUser.displayName
                            self.selectedPhotoURL = URL(string: access.originUser.photoURL)
                        } else {
                            ErrorManager.shared.logMessage(message: AlertMessage.userPremiumExpired)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .redacted(reason: vm.isSwitcherLoading ? .placeholder : [])
    }
    
    var sharedSection: some View {
        VStack {
            Divider()
                .padding(.horizontal)
            
            Button {
                ErrorManager.shared.premiumError = true
            } label: {
                HStack {
                    CustomIconView(imageName: "crown.fill", dimensions: 17)
                        .padding(.horizontal, 5)
                        .foregroundColor(PremiumManager.shared.isPremium ? .yellow : tm.selectedTheme.primaryColor)
                    Text("Premium")
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)
                }
                .foregroundColor(tm.selectedTheme.primaryLabel)
                .frame(height: 40)
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.horizontal)
            
            NavigationLink(destination: CategoryView()) {
                
                HStack {
                    CustomIconView(imageName: "square.grid.2x2", dimensions: 17)
                        .padding(.horizontal, 5)
                    Text("Categories")
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)
                }
                .foregroundColor(tm.selectedTheme.primaryLabel)
                .frame(height: 40)
                .padding([.horizontal])
                
            }
            
            Divider()
                .padding(.horizontal)
            
            NavigationLink(destination: ShortcutView()) {
                HStack {
                    CustomIconView(imageName: "plus.square.on.square", dimensions: 17)
                        .padding(.horizontal, 5)
                    
                    Text("Shortcuts")
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)
                }
                .foregroundColor(tm.selectedTheme.primaryLabel)
                .frame(height: 40)
                .padding([.horizontal])
            }
            
            Divider()
                .padding(.horizontal)
        }
    }
    
    func deviceName() -> String {
        var systemInfo = utsname()
        
        uname(&systemInfo)
        
        let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        
        return str
    }
    
    var contactSection: some View {
        VStack {
            Divider()
                .padding(.horizontal)
            
            Button(action: {
                MailHelper.shared.sendEmail(
                    subject: "Budgetify Support",
                    body: """
                    
                    --------------------
                    Email: \(email ?? "-")
                    iOS Version: \(UIDevice.current.systemVersion)
                    Device Model: \(deviceName())
                    App Version: \(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))
                    --------------------
                    """,
                    to: ConfigManager.shared.contactEmail
                ) { success in
                    if !success {
                        ErrorManager.shared.logMessage(message: AlertMessage.emailAppNotFound)
                    }
                }
            }, label: {
                HStack {
                    CustomIconView(imageName: "ellipsis.bubble", dimensions: 17)
                        .padding(.horizontal, 5)
                    
                    Text("Contact Support")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)
                }
                .foregroundColor(tm.selectedTheme.primaryColor)
                .frame(height: 40)
                .padding([.horizontal])
            })
            
            Divider()
                .padding(.horizontal)
            
            NavigationLink(destination: {
                RoadmapView(service: RoadmapService())
            }, label: {
                HStack {
                    CustomIconView(imageName: "lightbulb", dimensions: 17)
                        .padding(.horizontal, 5)

                    Text("Feature Roadmap")

                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)
                }
            })
            .foregroundColor(tm.selectedTheme.primaryColor)
            .frame(height: 40)
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            Button(action: {
                guard let writeReviewURL = URL(string: "https://apps.apple.com/us/app/budgetify-expense-tracker/id6443894407")
                else { return }
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            }, label: {
                HStack {
                    CustomIconView(imageName: "star", dimensions: 17)
                        .padding(.horizontal, 5)

                    Text("Leave a Review")

                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)

                }
                .foregroundColor(tm.selectedTheme.primaryColor)
                .frame(height: 40)
                .padding([.horizontal])
            })

            Divider()
                .padding(.horizontal)
        }
        .padding(.top, 30)
    }
    
    var logoutSection: some View {
        VStack {
            Divider()
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await vm.signOut(dismiss: dismiss)
                }
            }, label: {
                HStack {
                    CustomIconView(imageName: "door.left.hand.open", dimensions: 17)
                        .padding(.horizontal, 5)
                    
                    Text("Logout")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                }
                .foregroundColor(.red)
                .frame(height: 40)
                .padding([.horizontal])
            })
            .alert(isPresented: $vm.isErrorAlertShown) {
                Alert(title: Text("Authentication Failed"), message: Text("This operation is sensitive and requires recent authentication. Log in again before retrying this request"), dismissButton: .default(Text("OK")))
            }
            
            Divider()
                .padding(.horizontal)
        }
        .padding(.top, 30)
    }
    
    var settingSection: some View {
        VStack {
            Divider()
                .padding(.horizontal)
            
            NavigationLink(destination: SettingsView()) {
                HStack {
                    CustomIconView(imageName: "gear", dimensions: 17)
                        .padding(.horizontal, 5)
                    Text("Settings")
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)
                }
                .foregroundColor(tm.selectedTheme.primaryLabel)
                .frame(height: 40)
                .padding([.horizontal])
                
            }
            
            Divider()
                .padding(.horizontal)
            
            NavigationLink(destination: CurrencySheetView()) {
                HStack {
                    CustomIconView(imageName: "dollarsign", dimensions: 17)
                        .padding(.horizontal, 5)
                    Text("Currency")
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .padding(.trailing, 10)
                }
                .foregroundColor(tm.selectedTheme.primaryLabel)
                .frame(height: 40)
                .padding(.horizontal)
            }
            
            if userId == selectedUserId {
                Divider()
                    .padding(.horizontal)
                
                NavigationLink(destination: SharingView()) {
                    HStack {
                        CustomIconView(imageName: "person.2.fill", dimensions: 17)
                            .padding(.horizontal, 5)
                        Text("Account Sharing")
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 10)
                    }
                    .foregroundColor(tm.selectedTheme.primaryLabel)
                    .frame(height: 40)
                    .padding([.horizontal])
                    
                }
            }
            
            Divider()
                .padding(.horizontal)
            
        }
        .padding(.top, 30)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AccountViewModel(loginService: MockLoginService()))
            .environmentObject(SharingViewModel(sharingService: MockSharingService()))
            .environmentObject(ThemeManager())
    }
}

public struct TextFieldAlertModifier: ViewModifier {
    @State private var alertController: UIAlertController?
    
    @Binding var isPresented: Bool
    
    let title: String
    let text: String
    let message: String
    let placeholder: String
    let action: (String?) -> Void
    
    public func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            if isPresented, alertController == nil {
                let alertController = makeAlertController()
                self.alertController = alertController
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return
                }
                scene.windows.first?.rootViewController?.present(alertController, animated: true)
            } else if !isPresented, let alertController = alertController {
                alertController.dismiss(animated: true)
                self.alertController = nil
            }
        }
    }
    
    private func makeAlertController() -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        controller.addTextField {
            $0.placeholder = self.placeholder
            $0.text = self.text
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            shutdown()
        })
        
        controller.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.action(controller.textFields?.first?.text)
            shutdown()
        })
        
        return controller
    }
    
    private func shutdown() {
        isPresented = false
        alertController = nil
    }
}

extension View {
    public func deleteTextFieldAlert(
        isPresented: Binding<Bool>,
        title: String = "Enter DELETE to Confirm",
        message: String,
        text: String = "",
        placeholder: String = "",
        action: @escaping (String?) -> Void
    ) -> some View {
        self.modifier(TextFieldAlertModifier(isPresented: isPresented, title: title, text: text, message: message, placeholder: "DELETE", action: action))
    }
}
