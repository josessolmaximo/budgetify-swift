//
//  SharingEmailSheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 02/02/23.
//

import SwiftUI

struct SharingEmailSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm = SharingEmailSheetViewModel()
    @StateObject var em = ErrorManager.shared
    
    @EnvironmentObject var tm: ThemeManager
    @EnvironmentObject var sharingVM: SharingViewModel
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Email", text: $vm.recipientEmail)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(tm.selectedTheme.tertiaryLabel, lineWidth: 0.5)
                                .padding(-5)
                                .padding(.leading, -2.5)
                        )
                        .padding(.leading, 7.5)
                        .padding(.trailing, 5)
                }
                .padding(.bottom, 10)
                
                InfoBox(text: "The person you invite will have access to your data. The invited person needs to accept the invitation. Make sure to enter the right email address.")
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !vm.loading {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if vm.loading {
                        ProgressView()
                            .tint(tm.selectedTheme.tintColor)
                            .accessibilityIdentifier("loadingIndicator")
                    } else {
                        Button("Invite") {
                            Task {
                                await vm.sendInvite(sharingVM: sharingVM)
                            }
                        }
                    }
                }
            }
            .errorAlert(error: $em.serviceError)
            .errorAlert(error: $em.validationError)
            .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
            .onChange(of: vm.shouldSheetDismiss) { shouldDismiss in
                if shouldDismiss { dismiss() }
            }
        }
    }
}

struct SharingEmailSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SharingEmailSheetView()
            .environmentObject(ThemeManager())
            .environmentObject(SharingViewModel(sharingService: MockSharingService()))
    }
}
