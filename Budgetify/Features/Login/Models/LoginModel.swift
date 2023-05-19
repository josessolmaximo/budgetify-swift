//
//  LoginModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 20/12/22.
//

import Foundation

struct OnboardingPage: Hashable {
    var title: String
    var description: String
    var image: String
}

let onboardingPages = [
    OnboardingPage(title: "Track Your Expenses", description: "Budgetify makes it easy to track your expenses, so you can see where your money is going.", image: "doc.plaintext"),
    OnboardingPage(title: "Recurring Transactions", description: "Manage subscriptions and recurring bills by adding them and get reminded when one is due soon.", image: "arrow.2.squarepath"),
    OnboardingPage(title: "Set and Track Budgets", description: "Set budgets for different categories of expenses, so you can see how close you are to reaching them.", image: "chart.pie"),
    OnboardingPage(title: "Generate Reports", description: "Generate reports to help you understand your spending habits and make better decisions.", image: "chart.bar"),
]
