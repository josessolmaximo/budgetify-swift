//
//  CustomDatePicker.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 11/12/22.
//

import SwiftUI



struct CustomDatePicker: UIViewRepresentable {
    @Binding var date: Date
//    var range: ClosedRange<Date>
    var alignment: UISemanticContentAttribute = .forceLeftToRight
    
    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
//        datePicker.setContentHuggingPriority(.defaultLow, for: .horizontal)
        datePicker.sizeToFit()
        datePicker.semanticContentAttribute = alignment
        datePicker.subviews.first?.semanticContentAttribute = alignment
//        datePicker.minimumDate = range.lowerBound
//        datePicker.maximumDate = range.upperBound
        return datePicker
    }

    func updateUIView(_ datePicker: UIDatePicker, context: Context) {
        datePicker.date = date
    }

    func makeCoordinator() -> CustomDatePicker.Coordinator {
        Coordinator(date: $date)
    }

    class Coordinator: NSObject {
        private let date: Binding<Date>

        init(date: Binding<Date>) {
            self.date = date
        }

        @objc func changed(_ sender: UIDatePicker) {
            self.date.wrappedValue = sender.date
        }
    }
}
