//
//  AttributedTextView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 20/11/22.
//

import SwiftUI

struct AttributedTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textViewHeight: CGFloat
    
    let id: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.font = .systemFont(ofSize: 17)
        
        if text.isEmpty {
            textView.text = "Notes"
            textView.textColor = .tertiaryLabel
        } else {
            textView.textColor = UIColor(named: "default.primaryLabel")
            textView.attributedText = context.coordinator.updateAttributedString(string: text)
        }
        
        textView.delegate = context.coordinator
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = .white
        toolbar.isTranslucent = false
        toolbar.sizeToFit()

        let paddingStackView = UIStackView()
        paddingStackView.axis = .horizontal
        paddingStackView.alignment = .center
        paddingStackView.spacing = 8.0

        let leftPadding = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        leftPadding.width = 10.0

        let flexiblePadding = UIBarButtonItem(customView: paddingStackView)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let buttonImage = UIImage(systemName: "keyboard.chevron.compact.down")
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(buttonImage, for: .normal)
        button.addTarget(context.coordinator, action: #selector(context.coordinator.removeKeyboard), for: .touchUpInside)

        paddingStackView.addArrangedSubview(button)
        toolbar.items = [flexibleSpace, flexiblePadding]

        textView.inputAccessoryView = toolbar
       
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if text != "" {
            uiView.attributedText = context.coordinator.updateAttributedString(string: uiView.text)
        }
        
        recalculateHeight(view: uiView)
    }
    
    func recalculateHeight(view: UITextView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if textViewHeight != newSize.height {
            DispatchQueue.main.async {
                textViewHeight = newSize.height
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AttributedTextView
        
        init(_ parent: AttributedTextView) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.attributedText = updateAttributedString(string: textView.text)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if parent.text == "" {
                textView.text = "Notes"
                textView.textColor = .tertiaryLabel
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
        
        func updateAttributedString(string: String) -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: string)
            let splitString = string.split(separator: " ")
            let tags = splitString.filter({ $0.prefix(1) == "#" })
            let range = (string as NSString).range(of: string)
            
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor(named: "default.primaryLabel"), range: range)
            
            for tag in Set(tags) {
                let ranges = string.rangesForWord(String(tag))
                for range in ranges {
                    attributedString.addAttribute(.foregroundColor, value: UIColor(named: "#4772FA")!, range: range)
                    attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .semibold), range: range)
                }
            }
            
            return attributedString
        }
        
        @objc func removeKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

extension String {
    func rangesForWord(_ word: String) -> [NSRange] {
        var ranges: [NSRange] = []

        do {
            let regex = try NSRegularExpression(pattern: word, options: [.caseInsensitive])
            let items = regex.matches(in: self, options: [], range: NSRange(location: 0, length: (self as NSString).length))
            ranges = items.map{$0.range}
        } catch {
            return []
        }
        
        return ranges
    }
}
