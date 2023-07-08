//
//  ExpressionTextView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 08/07/23.
//

import UIKit
import SwiftUI
import Expression

struct ExpressionTextView: UIViewRepresentable {
    @Binding var text: String
    
    @Binding var amount: Decimal?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        if let amount = amount {
            let numberFormatter = NumberFormatter()
            
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 10
            
            let stringValue = numberFormatter.string(from: NSNumber(value: amount.doubleValue)) ?? ""
            
            textField.text = stringValue
        }
        
        textField.font = .systemFont(ofSize: 44, weight: .semibold)
        textField.placeholder = "0"
        textField.keyboardType = .decimalPad
        textField.delegate = context.coordinator
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor(Color("Keyboard"))
        toolbar.isTranslucent = false
        toolbar.sizeToFit()

        let paddingStackView = UIStackView()
        paddingStackView.axis = .horizontal
        paddingStackView.alignment = .center
        paddingStackView.spacing = 8.0
        
        let calculatorStackView = UIStackView()
        calculatorStackView.axis = .horizontal
        calculatorStackView.alignment = .center
        calculatorStackView.spacing = 8.0

        let leftPadding = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        leftPadding.width = 10.0

        let flexiblePadding = UIBarButtonItem(customView: paddingStackView)
        let calculatorSpace = UIBarButtonItem(customView: calculatorStackView)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        button.addTarget(context.coordinator, action: #selector(context.coordinator.removeKeyboard), for: .touchUpInside)

        let plusButton = UIButton(type: .system)
        plusButton.tintColor = .black
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.contentMode = .scaleAspectFit
        plusButton.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        plusButton.tag = 0
        plusButton.addTarget(context.coordinator, action: #selector(context.coordinator.calculatorButtonPressed(_:)), for: .touchUpInside)
        
        let minusButton = UIButton(type: .system)
        minusButton.tintColor = .black
        minusButton.setImage(UIImage(systemName: "minus"), for: .normal)
        minusButton.contentMode = .scaleAspectFit
        minusButton.imageEdgeInsets = UIEdgeInsets(top: 1.5, left: 1.5, bottom: 1.5, right: 1.5)
        minusButton.tag = 1
        minusButton.addTarget(context.coordinator, action: #selector(context.coordinator.calculatorButtonPressed(_:)), for: .touchUpInside)
        
        let multiplyButton = UIButton(type: .system)
        multiplyButton.tintColor = .black
        multiplyButton.setImage(UIImage(systemName: "asterisk"), for: .normal)
        multiplyButton.contentMode = .scaleAspectFit
        multiplyButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        multiplyButton.tag = 2
        multiplyButton.addTarget(context.coordinator, action: #selector(context.coordinator.calculatorButtonPressed(_:)), for: .touchUpInside)
        
        let divideButton = UIButton(type: .system)
        divideButton.tintColor = .black
        divideButton.setTitle("/", for: .normal)
        divideButton.titleLabel?.font = .systemFont(ofSize: 17)
        divideButton.tag = 3
        divideButton.addTarget(context.coordinator, action: #selector(context.coordinator.calculatorButtonPressed(_:)), for: .touchUpInside)
        
        let leftBracketButton = UIButton(type: .system)
        leftBracketButton.tintColor = .black
        leftBracketButton.setTitle("(", for: .normal)
        leftBracketButton.titleLabel?.font = .systemFont(ofSize: 18)
        leftBracketButton.tag = 4
        leftBracketButton.addTarget(context.coordinator, action: #selector(context.coordinator.calculatorButtonPressed(_:)), for: .touchUpInside)
        
        let rightBracketButton = UIButton(type: .system)
        rightBracketButton.tintColor = .black
        rightBracketButton.setTitle(")", for: .normal)
        rightBracketButton.titleLabel?.font = .systemFont(ofSize: 18)
        rightBracketButton.tag = 5
        rightBracketButton.addTarget(context.coordinator, action: #selector(context.coordinator.calculatorButtonPressed(_:)), for: .touchUpInside)

        calculatorStackView.addArrangedSubview(plusButton)
        calculatorStackView.addArrangedSubview(minusButton)
        calculatorStackView.addArrangedSubview(multiplyButton)
        calculatorStackView.addArrangedSubview(divideButton)
        calculatorStackView.addArrangedSubview(leftBracketButton)
        calculatorStackView.addArrangedSubview(rightBracketButton)
        
        paddingStackView.addArrangedSubview(button)
        
        toolbar.items = [calculatorSpace, flexibleSpace, flexiblePadding]

        textField.inputAccessoryView = toolbar
        
        context.coordinator.textField = textField
        
        textField.addTarget(self, action: #selector(context.coordinator.textFieldDidChange(_:)), for: .editingChanged)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ExpressionTextView?
        weak var textField: UITextField?
        
        init(_ parent: ExpressionTextView) {
            self.parent = parent
        }
        
        @objc func calculatorButtonPressed(_ button: UIButton) {
            switch button.tag {
            case 0: textField?.insertText("+")
            case 1: textField?.insertText("-")
            case 2: textField?.insertText("*")
            case 3: textField?.insertText("/")
            case 4: textField?.insertText("(")
            case 5: textField?.insertText(")")
            default: break
            }
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            guard let expressionText = textField.text else { return }
            
            do {
                let expression = Expression(expressionText)
                
                let expressionAmount = try expression.evaluate()
                
                parent?.amount = Decimal(expressionAmount)
            } catch {
                parent?.amount = nil
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            guard let expressionText = textField.text else { return }
            
            do {
                let expression = Expression(expressionText)
                
                let expressionAmount = try expression.evaluate()
                
                let numberFormatter = NumberFormatter()
                
                numberFormatter.minimumFractionDigits = 0
                numberFormatter.maximumFractionDigits = 10
                
                let stringValue = numberFormatter.string(from: NSNumber(value: expressionAmount)) ?? ""
                
                if expressionAmount.isFinite {
                    textField.text = "\(stringValue)"
                    parent?.amount = Decimal(expressionAmount)
                } else {
                    textField.text = ""
                    parent?.amount = nil
                }
                
            } catch {
                textField.text = ""
                parent?.amount = nil
            }
        }
        
        @objc func removeKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
