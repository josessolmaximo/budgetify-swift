//
//  TransactionItemView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 03/12/22.
//

import SwiftUI
import CoreLocation
import FirebaseAnalyticsSwift

struct TransactionItemView: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var transactionSheetVM: TransactionSheetViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm: TransactionItemViewModel
    @StateObject var mapVM: MapViewModel
    
    @ObservedObject var sm = SettingsManager.shared
    
    @Binding var transaction: Transaction
    
    @FocusState var focusedField: FocusedField?
    
    private let everyType: [RecurringType: Range<Int>] = [.daily: 1..<32, .weekly: 1..<53, .monthly: 1..<13]
    private let periodType: [RecurringType: String] = [.daily: "day", .monthly : "month", .weekly: "week"]
    
    private var formatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .ordinal
        return nf
    }
    
    var locationManager = CLLocationManager()
    
    public var mode: ItemMode
    
    enum ItemMode {
        case create
        case update
        case recurring
        case shortcut
    }
    
    init(transaction: Binding<Transaction>, mode: ItemMode) {
        self._transaction = transaction
        self._vm = StateObject(wrappedValue: TransactionItemViewModel(transaction: transaction))
        self._mapVM = StateObject(wrappedValue: MapViewModel(transaction: transaction.wrappedValue))
        
        self.mode = mode
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("", selection: $transaction.type, content: {
                    ForEach(TransactionType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                })
                .pickerStyle(.segmented)
                .onChange(of: transaction.type) { value in
                    transaction.category = categoryVM.getDefaultCategory(type: value)
                }
                .disabled(transactionSheetVM.doesTransactionExist)
                
                if transactionSheetVM.transactions.count > 1 {
                    Button {
                        if transactionSheetVM.transactions.count > 1 {
                            DispatchQueue.main.async {
                                self.transactionSheetVM.transactions.removeAll(where: {$0.id == transaction.id})
                            }
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .foregroundColor(.red)
                }
            }
            
            HStack {
                Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                    .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    .font(.system(size: 44))
                
                TextField("0", value: $transaction.amount, format: .number)
                    .foregroundColor(tm.selectedTheme.primaryLabel)
                    .font(.system(size: 44, weight: .semibold))
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .amount)
                
            }
            .padding(.vertical)
            
            HStack {
                if mode == .shortcut {
                    DatePicker(selection: .constant(Date()), in: Date()...Date()) {
                        HStack {
                            categoryPicker
                            
                            Spacer()
                        }
                    }
                } else if transactionSheetVM.isRecurringMode {
                    DatePicker(selection: $transaction.date, in: transaction.date...transaction.date) {
                        HStack {
                            categoryPicker
                            
                            Spacer()
                            
                            recurringButton
                        }
                    }
                } else {
                    DatePicker(selection: $transaction.date) {
                        HStack {
                            categoryPicker
                            
                            Spacer()
                            
                            recurringButton
                        }
                    }
                }
            }
            .onChange(of: transaction.date) { date in
                transaction.recurring.date = date
            }
            
            if transaction.recurring.type != .none {
                recurringInput
                
                recurringCustomInput
            }
            
            location
            
            HStack {
                notes
                
                VStack {
                    Menu {
                        Button(action: {
                            if PremiumManager.shared.isPremium {
                                transactionSheetVM.isCameraSheetShown = "camera"
                            } else {
                                ErrorManager.shared.premiumError = true
                            }
                        }, label: {
                            Text("Camera")
                            Image(systemName: "camera")
                            
                        })
                        
                        Button(action: {
                            if PremiumManager.shared.isPremium {
                                transactionSheetVM.isCameraSheetShown = "photo"
                            } else {
                                ErrorManager.shared.premiumError = true
                            }
                        }, label: {
                            Text("Choose a Photo")
                            Image(systemName: "photo.on.rectangle")
                        })
                    } label: {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(tm.selectedTheme.primaryColor)
                    }
                    .padding(.top, 11)
                    Spacer()
                }
            }
            
            if !transaction.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if transactionSheetVM.doesTransactionExist {
                            ForEach(Array(transaction.images.enumerated()), id: \.element){ index, image in
                                
                                FirebaseImage(size: .small, id: image)
                                    .onTapGesture {
                                        vm.selectedImage = index
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            vm.removeImage(index: index, id: image, transactionSheetVM: transactionSheetVM)
                                        } label: {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .sheet(item: $vm.selectedImage) { idx in
                                        ImageSheet(imagesString: transaction.images, selectedImage: idx)
                                    }
                            }
                            
                            ForEach(Array(vm.images.enumerated()), id: \.element) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            vm.removeImage(index: index, id: nil, transactionSheetVM: transactionSheetVM)
                                        } label: {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .onTapGesture {
                                        vm.selectedImage = index
                                    }
                                    .sheet(item: $vm.selectedImage) { idx in
                                        ImageSheet(images: vm.images, selectedImage: idx)
                                    }
                            }
                            .padding(.leading, 10)
                        } else {
                            ForEach(Array(vm.images.enumerated()), id: \.element) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            vm.removeImage(index: index, id: nil, transactionSheetVM: transactionSheetVM)
                                        } label: {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .onTapGesture {
                                        vm.selectedImage = index
                                    }
                                    .sheet(item: $vm.selectedImage) { idx in
                                        ImageSheet(images: vm.images, selectedImage: idx)
                                    }
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(height: 90)
                }
            }
        }
        .sheet(item: $transactionSheetVM.isCameraSheetShown) { mode in
            if mode == "camera" {
                CameraPicker { image, imageData in
                    vm.addImage(image: image, imageData: imageData, transactionSheetVM: transactionSheetVM)
                }
                .ignoresSafeArea()
            } else {
                ImagePicker(isCameraSheetShown: $transactionSheetVM.isCameraSheetShown) { image, imageData in
                    vm.addImage(image: image, imageData: imageData, transactionSheetVM: transactionSheetVM)
                }
            }
        }
        .onChange(of: transaction) { transaction in
            if let index = transactionSheetVM.transactions.firstIndex(where: { $0.id == transaction.id }) {
                transactionSheetVM.transactions[index] = transaction
            }
        }
    }
}

extension TransactionItemView {
    @ViewBuilder
    var recurringCustomInput: some View {
        if transaction.recurring.type == .custom {
            HStack {
                Image(systemName: "clock.arrow.2.circlepath")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Menu {
                    Menu {
                        ForEach(1...28, id: \.self) { num in
                            Button(action: {
                                transaction.recurring.amount = num
                                transaction.recurring.customType = .first
                            }, label: {
                                Text(formatter.string(from: num as NSNumber)!)
                            })
                        }
                    } label: {
                        Text("On the _ day of the month")
                    }
                    
                    Menu {
                        ForEach(1...28, id: \.self) { num in
                            Button(action: {
                                transaction.recurring.amount = num
                                transaction.recurring.customType = .last
                            }, label: {
                                Text(formatter.string(from: num as NSNumber)!)
                            })
                        }
                    } label: {
                        Text("On the last _ day of the month")
                    }
                    
                } label: {
                    if transaction.recurring.customType == .first {
                        Text("On the \(formatter.string(from: transaction.recurring.amount as NSNumber)!) day of the month")
                            .fontWeight(.medium)
                            .foregroundColor(Color("#4772FA"))
                            .frame(width: 300, alignment: .leading)
                    } else if transaction.recurring.customType == .last {
                        Text(transaction.recurring.amount == 1 ? "On the last day of the month" : "On the \(formatter.string(from: transaction.recurring.amount as NSNumber)!) to last day of the month")
                            .fontWeight(.medium)
                            .foregroundColor(Color("#4772FA"))
                            .frame(width: 300, alignment: .leading)
                    }
                }
                .frame(alignment: .leading)
                Spacer()
            }
            .padding(.top, 10)
        }
    }
    
    var recurringInput: some View {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            Menu {
                Picker("", selection: $transaction.recurring.type) {
                    ForEach(RecurringType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
            } label: {
                Text(transaction.recurring.type.rawValue)
                    .fontWeight(.medium)
                    .foregroundColor(Color("#4772FA"))
            }
            .disabled(transactionSheetVM.doesTransactionExist)
            
            Spacer()
            
            if transaction.recurring.type == .days {
                HStack {
                    ForEach(daysOfTheWeek.keys, id: \.self) { day in
                        Button(action: {
                            if let index = transaction.recurring.weekdays.firstIndex(of: day) {
                                transaction.recurring.weekdays.remove(at: index)
                            } else {
                                transaction.recurring.weekdays.append(day)
                            }
                        }, label: {
                            Text(day.prefix(1).uppercased())
                        })
                        .frame(width: 20)
                        .foregroundColor(transaction.recurring.weekdays.contains(day) ? Color("#4772FA") : Color("#929292"))
                        .disabled(transactionSheetVM.doesTransactionExist)
                    }
                }
            } else if transaction.recurring.type != .custom {
                Menu {
                    Picker("", selection: $transaction.recurring.amount) {
                        ForEach(everyType[transaction.recurring.type]!, id: \.self) { num in
                            if num == 1 {
                                Text("Every\(transaction.recurring.type == .daily ? "" : " ")\(periodType[transaction.recurring.type]!)")
                            } else {
                                Text("Every \(num) \(periodType[transaction.recurring.type]!)s")
                            }
                        }
                    }
                } label: {
                    if transaction.recurring.amount == 1 {
                        Text("Every\(transaction.recurring.type == .daily ? "" : " ")\(periodType[transaction.recurring.type]!)")
                            .fontWeight(.medium)
                            .foregroundColor(Color("#4772FA"))
                    } else {
                        Text("Every \(transaction.recurring.amount) \(periodType[transaction.recurring.type]!)s")
                            .fontWeight(.medium)
                            .foregroundColor(Color("#4772FA"))
                            .frame(width: 200, alignment: .trailing)
                    }
                }
                .disabled(transactionSheetVM.doesTransactionExist)
            }
        }
        .padding(.top, 10)
    }
    
    var recurringButton: some View {
        Button(action: {
            if transactionSheetVM.doesTransactionExist {
                vm.isRecurringPopoverShown = true
                transactionSheetVM.canDismiss = false
            } else {
                if transaction.recurring.type == .none {
                    transaction.recurring.type = .daily
                } else {
                    transaction.recurring.type = .none
                }
            }
        }, label: {
            Image(systemName: "arrow.2.squarepath")
                .foregroundColor(transaction.recurring.type == .none ? Color("#929292") : tm.selectedTheme.tintColor)
        })
        .alwaysPopover(isPresented: $vm.isRecurringPopoverShown) {
            Text("You can't change the recurring status of\ntransactions, please create a new one instead")
                .font(.subheadline)
                .padding()
        }
    }
    
    var location: some View {
        HStack {
            TextField("Location", text: $transaction.location.name)
                .focused($focusedField, equals: .location)
            Button(action: {
                vm.isLocationPickerShown.toggle()
            }, label: {
                Image(systemName: "map")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(tm.selectedTheme.primaryColor)
            })
        }
        .padding(.top, 10)
        .sheet(isPresented: $vm.isLocationPickerShown) {
            LocationSheet(mapVM: mapVM, locationManager: locationManager, isMapSheetShown: $vm.isLocationPickerShown, transaction: $transaction)
                .onAppear {
                    locationManager.delegate = mapVM
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.requestLocation()
                }
        }
    }
    
    var notes: some View {
        ZStack {
            TextEditor(text: $transaction.note)
                .focused($focusedField, equals: .note)
                .padding(.leading, -5)
            
            HStack {
                Text("Notes")
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                    
                Spacer()
            }
            .opacity(transaction.note.isEmpty ? 1 : 0)
            .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    var categoryPicker: some View {
        let category = categoryVM.getCategoryById(id: transaction.category)
        let originWallet = walletVM.getWalletById(id: transaction.originWallet)
        let destinationWallet = walletVM.getWalletById(id: transaction.destinationWallet)
        
        if transaction.type == .transfer {
            Menu {
                Picker("", selection: $transaction.originWallet) {
                    ForEach(walletVM.wallets){ wallet in
                        HStack {
                            Text(wallet.name)
                            CustomIconView(imageName: wallet.image, dimensions: 20)
                        }
                        .tag(wallet.id.uuidString)
                    }
                }
            } label: {
                CustomIconView(imageName: originWallet?.image ?? "circle.slash", dimensions: 20)
                    .redacted(reason: originWallet == nil ? .placeholder : [])
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
            
            Image(systemName: "arrow.forward")
            
            Menu {
                Picker("", selection: $transaction.destinationWallet) {
                    ForEach(walletVM.wallets){ wallet in
                        HStack {
                            Text(wallet.name)
                            CustomIconView(imageName: wallet.image, dimensions: 20)
                        }
                        .tag(wallet.id.uuidString)
                    }
                }
                
            } label: {
                CustomIconView(imageName: destinationWallet?.image ?? "circle.slash", dimensions: 20)
                    .redacted(reason: destinationWallet == nil ? .placeholder : [])
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
        } else {
            Menu {
                Picker("", selection: $transaction.originWallet) {
                    ForEach(walletVM.wallets){ wallet in
                        HStack {
                            Text(wallet.name)
                            CustomIconView(imageName: wallet.image, dimensions: 20)
                        }
                        .tag(wallet.id.uuidString)
                    }
                }
                
            } label: {
                CustomIconView(imageName: originWallet?.image ?? "circle.slash", dimensions: 20)
                    .redacted(reason: originWallet == nil ? .placeholder : [])
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
        }
        
        if transaction.type != .transfer {
            Rectangle()
                .frame(width: 1, height: 20)
                .foregroundColor(tm.selectedTheme.tertiaryLabel)
            
            let validCategories = categoryVM.categories.filter { item in
                return item.value.filter({$0.type == transaction.type}).count > 0
            }
            
            Menu {
                ForEach(validCategories.elements, id: \.key){ header, categories in
                    let validCategory = categories.filter({ !$0.isHidden && $0.type == transaction.type })
                    Menu {
                        Picker("", selection: $transaction.category) {
                            ForEach(validCategory){ category in
                                HStack {
                                    Text(category.name)
//                                    Text("A")
                                    CustomIconView(imageName: category.image, dimensions: 20)
                                }
                                .tag(category.id.uuidString)
                            }
                        }
                        .onChange(of: transaction.category) { newCategory in
                            if let wallet = categoryVM.getCategoryById(id: newCategory)?.defaultWallet, !wallet.isEmpty {
                                transaction.originWallet = wallet
                            }
                        }
                    } label: {
                        Text(header)
                        CustomIconView(imageName: validCategory.first(where: {!$0.image.contains("logo.")})?.image ?? "", dimensions: 20)
                    }
                    .foregroundColor(tm.selectedTheme.primaryColor)
                }
            } label: {
                CustomIconView(imageName: category?.image ?? "tray", dimensions: 20)
                    .redacted(reason: category == nil ? .placeholder : [])
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
        }
    }
}
