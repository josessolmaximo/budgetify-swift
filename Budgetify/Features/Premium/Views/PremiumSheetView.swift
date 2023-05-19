//
//  PremiumSheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 22/01/23.
//

import SwiftUI
import RevenueCat

struct PremiumSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm = PremiumSheetViewModel()
    
    @EnvironmentObject var tm: ThemeManager
    
    let onDismiss: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil){
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        header
                        
                        features
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            if let offering = vm.offering {
                                ForEach(offering.availablePackages, id: \.identifier) { package in
                                    product(package: package)
                                }
                            } else {
                                VStack {
                                    ProgressView()
                                        .tint(tm.selectedTheme.secondaryLabel)
                                }
                                .frame(height: 120)
                            }
                        }
                        .padding(.vertical, 20)
                        
                        Spacer()
                        
                        if vm.selected?.storeProduct.pricePerMonth != nil {
                            Text("Cancel Anytime - Billed \(vm.selected?.identifier ?? "")")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        } else {
                            Text("Billed Once")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        }
                        
                        continueButton
                        
                        links
                    }
                    .padding(.horizontal)
                    .frame(minHeight: proxy.size.height + proxy.safeAreaInsets.bottom)
                    .navigationBarTitleDisplayMode(.inline)
                    .alert("Purchase Failed", isPresented: .constant(vm.error != nil), actions: {
                        Button("OK") {
                            vm.error = nil
                        }
                    }, message: {
                        Text(vm.error?.description ?? "An Unknown Error Occured")
                    })
                    .onChange(of: vm.shouldSheetDismiss, perform: { shouldDismiss in
                        if shouldDismiss {
                            if let onDismiss = onDismiss {
                                onDismiss()
                            } else {
                                dismiss()
                            }
                        }
                    })
                    .navigationBarHidden(true)
                }
            }
            
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct PremiumSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSheetView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
        
        PremiumSheetView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}

extension PremiumSheetView {
    @ViewBuilder
    var header: some View {
        HStack {
            Spacer()
            
            Button(action: {
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    dismiss()
                }
            }, label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24))
            })
            .tint(tm.selectedTheme.primaryColor)
        }
        .padding(.top)
        
        HStack {
            Text("Upgrade to Premium to Unlock All Features")
                .font(.system(size: 32, weight: .bold))
            
            Spacer()
        }
        .padding(.bottom, 5)
        
        HStack {
            Text("Track, Manage and Analyze your expenses easier with our premium features.")
                .fontWeight(.medium)
                .foregroundColor(tm.selectedTheme.secondaryLabel)

            Spacer()
        }
    }
    var continueButton: some View {
        Button(action: {
            if !vm.loading {
                Task {
                    await vm.purchase()
                }
            }
        }, label: {
            if vm.loading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
            } else {
                Text(vm.selected?.storeProduct.introductoryDiscount?.subscriptionPeriod.duration == nil ? "Continue" : "Continue with Trial")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .foregroundColor(.white)
            }
        })
        .buttonStyle(.borderedProminent)
        .tint(tm.selectedTheme.tintColor)
    }
    
    var links: some View {
        ZStack {
            HStack {
                if let url = URL(string: ConfigManager.shared.termsOfUseLink){
                    Link(destination: url) {
                        Text("Terms of Use")
                            .underline()
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(tm.selectedTheme.primaryLabel)
                    }
                }
                
                Spacer()
                
                if let url = URL(string: ConfigManager.shared.privacyPolicyLink){
                    Link(destination: url) {
                        Text("Privacy Policy")
                            .underline()
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(tm.selectedTheme.primaryLabel)
                    }
                }
            }
            
            Button(action: {
                Task {
                    await vm.restore()
                }
            }, label: {
                Text("Restore Purchase")
                    .underline()
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(tm.selectedTheme.primaryLabel)
            })
        }
        .padding(.bottom, 40)
        .padding(.top, 5)
    }
    
    func product(package: Package) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text(package.identifier)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            
            Text(package.localizedPriceString)
                .font(.system(size: 27, weight: .bold))
                .frame(minHeight: 30)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            
            if let pricePerMonth = package.storeProduct.pricePerMonth {
                let divided = pricePerMonth.dividing(by: 4).doubleValue
                
                Text("\(divided > 10000 ? divided.abbreviated : divided.toString ) / week")
                    .font(.system(size: 13))
                    .foregroundColor(tm.selectedTheme.secondaryColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            } else {
                Text("Pay Once")
                    .font(.system(size: 13))
                    .foregroundColor(tm.selectedTheme.secondaryColor)
            }
            
            Spacer()
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding(10)
        .onTapGesture {
            withAnimation {
                vm.selected = package
            }
        }
        .overlay(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(vm.selected == package ? tm.selectedTheme.primaryLabel : tm.selectedTheme.tertiaryLabel, lineWidth: 1)
                    .padding(.top, package.storeProduct.introductoryDiscount != nil ? -20 : 0)
                
                if let pricePerMonth = package.storeProduct.pricePerMonth?.decimalValue {
                    let maxPricePerMonth = vm.offering?.availablePackages.compactMap({ package in
                        return package.storeProduct.pricePerMonth?.decimalValue
                    }).max() ?? 0
                    
                    let savings = (maxPricePerMonth - pricePerMonth) / maxPricePerMonth * 100
                    
                    if savings > 0 {
                        VStack {
                            Text("Save \(String(format: "%.0f", savings.doubleValue))%")
                                .frame(height: 22)
                                .frame(maxWidth: .infinity)
                                .minimumScaleFactor(0.5)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.green)
                                .cornerRadius(5)
                                .padding(.top, 4)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                    }
                }

                
                if let duration = package.storeProduct.introductoryDiscount?.subscriptionPeriod.duration {
                    VStack {
                        Text("\(duration) Trial")
                            .frame(height: 22)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.5)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(tm.selectedTheme.backgroundColor)
                            .background(tm.selectedTheme.primaryLabel)
                            .cornerRadius(8, corners: [.topLeft, .topRight])
                            .offset(y: -20)
                        
                        Spacer()
                    }
                }
                
                if vm.activeProducts.contains(package.storeProduct.productIdentifier){
                    Text("Current")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(tm.selectedTheme.secondaryLabel)
                        .offset(y:  package.storeProduct.introductoryDiscount?.subscriptionPeriod.duration == nil ? -75 : -95)
                }
            }
        )
        .scaleEffect(vm.selected == package ? 1.1 : 1)
    }
    
    var features: some View {
        VStack(spacing: 10) {
            HStack {
                Text("FEATURES")
                    .font(.system(size: 13, weight: .semibold))
                
                Spacer()
                
                Text("FREE")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 40)
                
                Text("PREMIUM")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 70)
            }
            
            ForEach([
                ("Add Multiple Transactions", ConfigManager.shared.paywallLimits["transactions"] ?? 20),
                ("Wallets", ConfigManager.shared.paywallLimits["wallets"] ?? 5),
                ("Custom Subcategories", ConfigManager.shared.paywallLimits["subcategories"] ?? 3),
                ("Budgets", ConfigManager.shared.paywallLimits["budgets"] ?? 1)
            ], id: \.0) { feature in
                HStack {
                    Text(feature.0)
                        .font(.system(size: 17, weight: .medium))
                    
                    Spacer()
                    
                    Text("\(feature.1)")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 40)
                    
                    Image(systemName: "infinity")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 70)
                }
            }
            
            ForEach([
                "Add Favicons",
                "Account Sharing",
                "Custom Categories",
                "Image Attachments",
            ], id: \.self) { feature in
                HStack {
                    Text(feature)
                        .font(.system(size: 17, weight: .medium))
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 40)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(width: 70)
                }
            }
        }
        .padding(.vertical)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}


