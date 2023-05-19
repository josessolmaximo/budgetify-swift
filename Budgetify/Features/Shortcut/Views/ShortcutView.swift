//
//  ShortcutView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 26/04/23.
//

import SwiftUI

struct ShortcutView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var vm: ShortcutViewModel
    @EnvironmentObject private var tm: ThemeManager
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            if vm.shortcuts.isEmpty {
                placeholder
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        Spacer()
                            .frame(height: 0)
                        
                        ForEach(vm.shortcuts) { shortcut in
                            HStack(alignment: .bottom) {
                                CustomIconView(imageName: shortcut.image, dimensions: 20)
                                    .foregroundColor(shortcut.color.stringToColor())
                                
                                Text(shortcut.name)
                                    .font(.system(size: 17, weight: .semibold))
                                    .frame(height: 18)
                                
                                if shortcut.slot != 0 {
                                    Text("Slot \(shortcut.slot)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(tm.selectedTheme.secondaryLabel)
                                }
                                
                                Spacer()
                                
                                Button {
                                    vm.selectedShortcut = shortcut
                                } label: {
                                    CustomIconView(imageName: "gear", dimensions: 20)
                                }
                                .foregroundColor(tm.selectedTheme.primaryColor)
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.horizontal)
                            
                            ForEach(shortcut.transactions) { transaction in
                                TransactionRow(selectedTransaction: .constant(nil), transaction: transaction, mode: .shortcut)
                                    .frame(height: 40)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Shortcuts")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(CustomBackButtonModifier(dismiss: dismiss))
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.selectedShortcut = Shortcut(name: "", image: "house", color: defaultColors.blue.rawValue, transactions: [])
                } label: {
                    Image(systemName: "plus")
                }
                .foregroundColor(tm.selectedTheme.primaryColor)
            }
        }
        .sheet(item: $vm.selectedShortcut) { shortcut in
            ShortcutSheetView(shortcut: shortcut)
                .environmentObject(vm)
        }
    }
}

struct ShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutView()
            .withPreviewEnvironmentObjects()
    }
}

extension ShortcutView {
    var placeholder: some View {
        VStack {
            VStack(spacing: 10) {
                HStack {
                    Text("What are shortcuts?")
                        .font(.system(size: 28, weight: .semibold))
                    
                    Spacer()
                }
                
                HStack {
                    Text("Shortcuts are an easy way to add transactions from widgets")
                        .foregroundColor(tm.selectedTheme.secondaryLabel)
                    Spacer()
                }
                
                HStack {
                    Text("Example:")
                        .fontWeight(.semibold)
                        .foregroundColor(tm.selectedTheme.primaryLabel)
                    
                    Spacer()
                }
                
                HStack {
                    Text("If you spend $5 on parking and $3 on coffee everytime you go to work, just add a shortcut to add both transactions at once.")
                        .foregroundColor(tm.selectedTheme.secondaryLabel)
                    
                    Spacer()
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tm.selectedTheme.tertiaryLabel, lineWidth: 2)
            )
            .padding(.horizontal, 40)
            .padding(.top)
            
            Spacer()
        }
    }
}
