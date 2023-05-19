//
//  SharingView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/12/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct SharingView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var tm: ThemeManager
    @EnvironmentObject var vm: SharingViewModel
    @StateObject var em = ErrorManager.shared
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 5) {
                    HStack {
                        Text("People With Access")
                            .font(.subheadline.weight(.medium))
                            
                        Spacer()
                        
                        Button(action: {
                            if PremiumManager.shared.isPremium {
                                vm.isEmailSheetShown = true
                            } else {
                                ErrorManager.shared.premiumError = true
                            }
                        }, label: {
                            Image(systemName: "plus")
                                .font(.subheadline)
                        })
                    }
                    .unredacted()
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    if vm.shared.isEmpty {
                        Text("No one has access")
                            .font(.subheadline)
                            .foregroundColor(tm.selectedTheme.secondaryLabel)
                            .unredacted()
                    }
                    
                    ForEach(vm.shared, id: \.self){ shared in
                        HStack {
                            ProfilePictureView(photoURL: URL(string: shared.recipientUser.photoURL), dimensions: 30)
                            
                            
                            VStack(alignment: .leading) {
                                Text(shared.recipientUser.displayName)
                                    .fontWeight(.medium)
                                
                                Text(shared.recipientUser.email)
                                    .font(.subheadline)
                                    .tint(tm.selectedTheme.primaryLabel)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        .frame(height: 50)
                        .onTapGesture {
                            vm.selectedAccess = shared
                        }
                    }
                    
                    HStack {
                        Text("Invites")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                    }
                    .unredacted()
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    if vm.invites.isEmpty {
                        Text("You have no pending invites")
                            .font(.subheadline)
                            .foregroundColor(tm.selectedTheme.secondaryLabel)
                            .unredacted()
                    }
                    
                    ForEach(vm.invites) { invite in
                        HStack {
                            Text(invite.originEmail)
                                .tint(tm.selectedTheme.primaryLabel)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await vm.updateInvite(invite: invite, action: .accepted)
                                }
                            }, label: {
                                Image(systemName: "checkmark")
                            })
                            
                            Button(action: {
                                Task {
                                    await vm.updateInvite(invite: invite, action: .denied)
                                }
                            }, label: {
                                Image(systemName: "xmark")
                            })
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .redacted(reason: vm.sharingLoading || vm.invitesLoading ? .placeholder : [])
            }
            .sheet(isPresented: $em.premiumError, content: {
                PremiumSheetView()
            })
            .refreshable {
                Task {
                    await vm.getData()
                }
            }
        }
        .navigationTitle("Sharing")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(CustomBackButtonModifier(dismiss: dismiss))
        .foregroundColor(tm.selectedTheme.primaryLabel)
        .sheet(item: $vm.selectedAccess) { sharingAccess in
            SharingAccessSheetView(sharingAccess: sharingAccess)
        }
        .sheet(isPresented: $vm.isEmailSheetShown, content: {
            SharingEmailSheetView()
        })
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct SharingView_Previews: PreviewProvider {
    static var previews: some View {
        SharingView()
            .environmentObject(SharingViewModel(sharingService: MockSharingService()))
            .environmentObject(ThemeManager())
    }
}
