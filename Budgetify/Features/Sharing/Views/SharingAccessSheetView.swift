//
//  SharingAccessSheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/12/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct SharingAccessSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var tm: ThemeManager
    @EnvironmentObject var sharingVM: SharingViewModel
    
    @StateObject var vm: SharingAccessSheetViewModel
    
    @StateObject var em = ErrorManager.shared
    
    init(sharingAccess: SharingAccess) {
        self._vm = StateObject(wrappedValue: SharingAccessSheetViewModel(sharingAccess: sharingAccess))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                HStack {
                    ProfilePictureView(photoURL: URL(string: vm.sharingAccess.recipientUser.photoURL), dimensions: 30)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Name", text: $vm.sharingAccess.recipientUser.displayName)
                            .font(.system(size: 17, weight: .medium))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        
                        Text(vm.sharingAccess.recipientUser.email)
                            .font(.subheadline)
                            .tint(tm.selectedTheme.primaryLabel)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 15)
                
                HStack() {
                    Text("Permissions")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                }
                
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(tm.selectedTheme.tertiaryLabel)
                
                HStack {
                    Text("Read")
                        .fontWeight(.medium)
                    Spacer()
                    Checkbox(isChecked: $vm.sharingAccess.permissions.read)
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text("Create")
                        .fontWeight(.medium)
                    Spacer()
                    Checkbox(isChecked: $vm.sharingAccess.permissions.create)
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text("Update")
                        .fontWeight(.medium)
                    Spacer()
                    Checkbox(isChecked: $vm.sharingAccess.permissions.update)
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text("Delete")
                        .fontWeight(.medium)
                    Spacer()
                    Checkbox(isChecked: $vm.sharingAccess.permissions.delete)
                }
                .padding(.vertical, 5)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(tm.selectedTheme.tertiaryLabel)
                
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
                    Button(role: .destructive) {
                        Task {
                            await vm.deleteSharing(sharingVM: sharingVM)
                        }
                    } label: {
                        Text("Delete")
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if vm.loading {
                        ProgressView()
                            .tint(tm.selectedTheme.tintColor)
                            .accessibilityIdentifier("loadingIndicator")
                    } else {
                        Button("Save") {
                            Task {
                                await vm.updateSharing(sharingVM: sharingVM)
                            }
                        }
                    }
                }
            }
            .onChange(of: vm.shouldSheetDismiss) { value in
                if value {
                    dismiss()
                }
            }
        }
        .errorAlert(error: $em.serviceError)
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

//struct SharingAccessSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SharingAccessSheetView(sharingAccess: SharingAccess(id: "", email: "josessolmaximo.developer@gmail.com", photoURL: "https://lh3.googleusercontent.com/a/AEdFTp6Q0ljoPwNNoo9KPZhwNGm7W9U68hbuUKgxAgK6=s96-c", displayName: "Joses Solmaximo", permissions: .init(create: true, read: true, update: true, delete: true)))
//            .environmentObject(ThemeManager())
//            .environmentObject(SharingViewModel(sharingService: MockSharingService()))
//    }
//}
