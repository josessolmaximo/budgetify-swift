//
//  IconPickerView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/11/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject private var vm = IconPickerViewModel()
    
    @ObservedObject var em = ErrorManager.shared
    
    let onDismiss: (_ image: String) -> Void
    
    init(onDismiss: @escaping (_ image: String) -> Void) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack {
            HStack {
                if vm.iconType == .emoji {
                    SearchTextField(keyword: Binding(get: {
                        vm.emojiText
                    }, set: {
                        vm.emojiText = String($0.prefix(1))
                    }), placeholder: "Enter an emoji or character")
                    .keyboardType(.default)
                } else if vm.iconType == .favicon {
                    SearchTextField(keyword: $vm.searchText, placeholder: "Enter a website's URL")
                        .keyboardType(.URL)
                        .onSubmit {
                            if vm.iconType == .favicon {
                                Task {
                                    await vm.requestFavIconUrl(domain: vm.searchText)
                                }
                            }
                        }
                } else {
                    SearchTextField(keyword: $vm.searchText, placeholder: "Search")
                        .keyboardType(.default)
                }
                
                if !vm.isFavIconLoading {
                    if vm.iconType == .emoji && !vm.emojiText.isEmpty {
                        Button(action: {
                            dismiss()
                            onDismiss(vm.emojiText)
                        }, label: {
                            Text("Done")
                        })
                        .frame(height: 30)
                    } else {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Cancel")
                        })
                        .frame(height: 30)
                    }
                } else {
                    VStack {
                        ProgressView()
                            .tint(tm.selectedTheme.tintColor)
                    }
                    .frame(height: 30)
                }
            }
            .padding(.trailing, 20)
            .padding(.leading, 6)
            .padding(.top, 12)
            
            Picker("", selection: $vm.iconType) {
                ForEach(IconType.allCases, id: \.rawValue) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            ScrollView {
                if vm.iconType == .favicon {
                    if vm.favIcons.isEmpty {
                        InfoBox(text: "Enter a website URL to get a favicon, then pick one of your choice.\n\nIcons may be blurry due to resizing.\n\nSome websites don't support favicons, their icons may not load properly!")
                            .padding()
                    } else {
                        let columns: [GridItem] = [
                            .init(.adaptive(minimum: 20)),
                            .init(.adaptive(minimum: 20)),
                            .init(.adaptive(minimum: 20)),
                            .init(.adaptive(minimum: 20)),
                            .init(.adaptive(minimum: 20)),
                            .init(.adaptive(minimum: 20)),
                            .init(.adaptive(minimum: 20)),
                        ]
                        
                        Spacer()
                            .frame(height: 10)
                        
                        HStack {
                            Text("Recommended Icons")
                                .font(.system(size: 13, weight: .semibold))
                            +
                            Text(" - from Google")
                                .font(.system(size: 13))
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, alignment: .center) {
                            ForEach(vm.favIcons.filter({ $0.isRecommended })) { icon in
                                favIconButton(icon: icon)
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Other Icons")
                                .font(.system(size: 13, weight: .semibold))
                            +
                            Text(" - from other services")
                                .font(.system(size: 13))
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, alignment: .center) {
                            ForEach(vm.favIcons.filter({ !$0.isRecommended })) { icon in
                                favIconButton(icon: icon)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if vm.iconType == .emoji {
                    InfoBox(text: "Enter an emoji or a character in the searchbar and hit done, maximum 1 emoji or character")
                        .padding()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(stride(from: 0, to: symbols[vm.iconType.rawValue]?.filter({
                            $0.contains(vm.searchText.lowercased()) || vm.searchText.isEmpty
                        }).count ?? 0, by: 7)), id: \.self) { index in
                            HStack(spacing: 30) {
                                iconCell(index: index)
                                iconCell(index: index + 1)
                                iconCell(index: index + 2)
                                iconCell(index: index + 3)
                                iconCell(index: index + 4)
                                iconCell(index: index + 5)
                                iconCell(index: index + 6)
                            }
                        }
                        .environmentObject(vm)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 30)
                    }
                    
                }
            }
            .onChange(of: vm.iconType) { _ in
                vm.searchText = ""
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .errorAlert(error: $em.serviceError)
        .sheet(isPresented: $em.premiumError, content: {
            PremiumSheetView(lastScreen: self.pageTitle)
        })
    }
}

struct IconPickerView_Previews: PreviewProvider {
    static var previews: some View {
        IconPickerView { _ in
            
        }
        .withPreviewEnvironmentObjects()
    }
}

extension IconPickerView {
    func favIconButton(icon: FavIcon) -> some View {
        VStack {
            Button(action: {
                if PremiumManager.shared.isPremium {
                    dismiss()
                    
                    onDismiss(icon.src ?? "")
                    
                    AnalyticService.incrementUserProperty(.favicons, value: 1)
                    
                    if let iconSrc = icon.src {
                        AnalyticService.appendUserProperty(.faviconURLs, value: [iconSrc])
                    }
                } else {
                    ErrorManager.shared.premiumError = true
                }
            }, label: {
                CustomIconView(imageName: icon.src ?? "")
            })
            .foregroundColor(tm.selectedTheme.primaryColor)
            
            let size = (icon.sizes ?? "")
            Text(size.isEmpty ? " " : size)
                .font(.system(size: 10))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
    
    @ViewBuilder
    func iconCell(index: Int) -> some View {
        let displayedSymbols = symbols[vm.iconType.rawValue]?.filter({
            $0.contains(vm.searchText.lowercased()) || vm.searchText.isEmpty
        }) ?? []
        
        if index < displayedSymbols.count  {
            Button(action: {
                dismiss()
                
                onDismiss(displayedSymbols[index])
            }, label: {
                CustomIconView(imageName: displayedSymbols[index])
            })
            .foregroundColor(tm.selectedTheme.primaryColor)
        } else {
            Color.clear
                .frame(width: 25, height: 25)
        }
    }
}
