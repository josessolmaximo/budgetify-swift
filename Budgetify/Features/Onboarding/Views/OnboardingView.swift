//
//  OnboardingView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 08/05/23.
//

import SwiftUI
import StoreKit
import AVKit
import Mixpanel

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("requestedRating") var requestedRating = false
    
    @EnvironmentObject private var tm: ThemeManager
    
    @State private var selectedPage: OnboardingPage = .wallet
    
    enum OnboardingVideo {
        static let walletLight = Bundle.main.url(forResource: "onboarding_wallet_light", withExtension: "mp4")!
        static let walletDark = Bundle.main.url(forResource: "onboarding_wallet_dark", withExtension: "mp4")!
        static let iconLight = Bundle.main.url(forResource: "onboarding_icon_light", withExtension: "mp4")!
        static let iconDark = Bundle.main.url(forResource: "onboarding_icon_dark", withExtension: "mp4")!
        static let transactionLight = Bundle.main.url(forResource: "onboarding_transaction_light", withExtension: "mp4")!
        static let transactionDark = Bundle.main.url(forResource: "onboarding_transaction_dark", withExtension: "mp4")!
    }
    
    enum OnboardingPage {
        case wallet
        case icon
        case transaction
        
        var title: String {
            switch self {
            case .wallet: return "Creating a Wallet"
            case .icon: return "Choosing an Icon"
            case .transaction: return "Creating Transactions"
            }
        }
        
        var pageIndex: Int {
            switch self {
            case .wallet: return 0
            case .icon: return 1
            case .transaction: return 2
            }
        }
    }
    
    var body: some View {
        NavigationView {
            firstPage
        }
        .onAppear {
            AnalyticService.updateUserProperty(.shownOnboarding, value: true)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                OnboardingView()
                    .withPreviewEnvironmentObjects()
            }
    }
}

extension OnboardingView {
    func requestRating(){
        guard ConfigManager.shared.onboarding.requestRating else { return }
        
        var windowKey: UIWindow? {
            UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
        }
        
        guard let windowScene = windowKey?.windowScene else { return }
        
        SKStoreReviewController.requestReview(in: windowScene)
        
        requestedRating = true
        
        AnalyticService.updateUserProperty(.requestedRating, value: true)
        
        Mixpanel.mainInstance().track(event: "Sign Up", properties: [
            "shownOnboarding": true,
            "skippedOnboarding": false,
            "requestedRating": true,
        ])
    }
    
    func replayVideo(page: OnboardingPage){
        switch page {
        case .wallet:
            PlayerView.postReplayNotification(.replayWalletVideo)
        case .icon:
            PlayerView.postReplayNotification(.replayIconVideo)
        case .transaction:
            PlayerView.postReplayNotification(.replayTransactionVideo)
        }
    }
    
    var firstPage: some View {
        VStack(alignment: .leading, spacing: 5) {
            Spacer()
            
            TabView(selection: Binding(get: {
                selectedPage
            }, set: { page in
                selectedPage = page
                replayVideo(page: page)
            })) {
                ZStack {
                    PlayerView(url: colorScheme == .light ? OnboardingVideo.walletLight : OnboardingVideo.walletDark, notificationName: .replayWalletVideo)
                }
                .tag(OnboardingPage.wallet)
                
                ZStack {
                    PlayerView(url: colorScheme == .light ? OnboardingVideo.iconLight : OnboardingVideo.iconDark, notificationName: .replayIconVideo)
                }
                .tag(OnboardingPage.icon)
                
                ZStack {
                    PlayerView(url: colorScheme == .light ? OnboardingVideo.transactionLight : OnboardingVideo.transactionDark, notificationName: .replayTransactionVideo)
                }
                .tag(OnboardingPage.transaction)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            HStack {
                if selectedPage == .transaction && ConfigManager.shared.onboarding.showPaywall {
                    NavigationLink {
                        PremiumSheetView(lastScreen: self.pageTitle) {
                            dismiss()
                            
                            requestRating()
                        }
                        .navigationBarHidden(true)
                    } label: {
                        Text("Next")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 35)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(tm.selectedTheme.tintColor)
                    .padding(.horizontal, 40)
                    .padding(.bottom)
                } else {
                    Button {
                        withAnimation {
                            switch selectedPage {
                            case .wallet:
                                selectedPage = .icon
                                replayVideo(page: .icon)
                            case .icon:
                                selectedPage = .transaction
                                replayVideo(page: .transaction)
                            case .transaction:
                                dismiss()
                                
                                requestRating()
                            }
                        }
                    } label: {
                        Text("Next")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 35)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(tm.selectedTheme.tintColor)
                    .padding(.horizontal, 40)
                    .padding(.bottom)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                    
                    AnalyticService.updateUserProperty(.skippedOnboarding, value: true)
                    
                    Mixpanel.mainInstance().track(event: "Sign Up", properties: [
                        "shownOnboarding": true,
                        "skippedOnboarding": true,
                        "requestedRating": false,
                    ])
                } label: {
                    Text("Skip")
                        .foregroundColor(tm.selectedTheme.secondaryLabel)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(selectedPage.pageIndex + 1) of 3")
                    .foregroundColor(tm.selectedTheme.secondaryLabel)
            }
        }
        .navigationBarTitle(selectedPage.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlayerView: UIViewRepresentable {
    let url: URL
    let notificationName: Notification.Name
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        guard let playerView = uiView as? LoopingPlayerUIView else { return }
        playerView.updatePlayer(with: url)
    }

    func makeUIView(context: Context) -> UIView {
        let playerView = LoopingPlayerUIView(frame: .zero, url: url, notificationName: notificationName)
        return playerView
    }
}

extension PlayerView {
    static func postReplayNotification(_ name: Notification.Name){
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        }
    }
}

extension Notification.Name {
    static let replayWalletVideo = NSNotification.Name("replayWalletVideo")
    static let replayIconVideo = NSNotification.Name("replayIconVideo")
    static let replayTransactionVideo = NSNotification.Name("replayTransactionVideo")
}

class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, url: URL, notificationName: Notification.Name) {
        super.init(frame: frame)
        
        let fileUrl = url
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVQueuePlayer()
        playerLayer.player = player
        layer.addSublayer(playerLayer)
         
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(replayVideo), name: notificationName, object: nil)
    }
    
    @objc func replayVideo(){
        playerLooper?.loopingPlayerItems.forEach({ $0.seek(to: .zero, completionHandler: nil) })
    }
    
    func updatePlayer(with url: URL) {
        playerLooper?.disableLooping()
        
        let fileUrl = url
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVQueuePlayer()
        playerLayer.player = player
        layer.addSublayer(playerLayer)
         
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
