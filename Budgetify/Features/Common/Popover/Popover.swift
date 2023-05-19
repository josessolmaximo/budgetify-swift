//
//  Popover.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 29/12/22.
//

import SwiftUI
import UIKit

struct PopoverContent: View {
    var body: some View {
        Text("This should be presented\nin a popover.")
            .font(.subheadline)
            .padding()
    }
}

class ContentViewController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V:View {
    var isPresented: Binding<Bool>
    var hasBeenPresented: Binding<Bool>
    
    init(rootView: V, isPresented: Binding<Bool>, hasBeenPresented: Binding<Bool>) {
        self.isPresented = isPresented
        self.hasBeenPresented = hasBeenPresented
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        preferredContentSize = size
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        DispatchQueue.main.async {
            self.isPresented.wrappedValue = false
            self.hasBeenPresented.wrappedValue = false
        }
    }
}

struct AlwaysPopoverModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    
    let isPresented: Binding<Bool>
    let contentBlock: () -> PopoverContent
    
    @State var hasBeenPresented = false
    
    private struct Store {
        var anchorView = UIView()
    }
    
    @State private var store = Store()
    
    func body(content: Content) -> some View {
        if isPresented.wrappedValue && !hasBeenPresented {
            presentPopover()
        }
        
        return content
            .background(InternalAnchorView(uiView: store.anchorView))
    }
    
    private func presentPopover() {
        let contentController = ContentViewController(rootView: contentBlock(), isPresented: isPresented, hasBeenPresented: $hasBeenPresented)
        contentController.modalPresentationStyle = .popover
        
        let view = store.anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.delegate = contentController
        
        guard let sourceVC = view.closestVC() else { return }
//        if let presentedVC = sourceVC.presentedViewController {
//            presentedVC.dismiss(animated: true) {
//                sourceVC.present(contentController, animated: true)
//            }
//        } else {
            sourceVC.present(contentController, animated: true)
        DispatchQueue.main.async {
            self.hasBeenPresented = true
        }
        
//        }
    }
    
    private struct InternalAnchorView: UIViewRepresentable {
        typealias UIViewType = UIView
        let uiView: UIView
        
        func makeUIView(context: Self.Context) -> Self.UIViewType {
            uiView
        }
        
        func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
    }
}

extension View {
    public func alwaysPopover<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self.modifier(AlwaysPopoverModifier(isPresented: isPresented, contentBlock: content))
    }
}

extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
