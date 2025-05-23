//
//  ExpenseManager.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import Foundation

// ObservableObject, a SwiftUI protocol that allows the class to publish changes to its properties

class ExpenseManager: ObservableObject {
    @Published var expenses: [Expense] = []
    
    init() {
        // Create mock data
        let categories = ExpenseCategory.allCases
        let descriptions = [
            "Groceries", "Taxi ride", "Electric bill", "Movie tickets",
            "Dinner out", "Bus fare", "Water bill", "Concert",
            "Lunch", "Gas", "Internet", "Books", "Coffee", "Parking", "Gym"
        ]
        
        for i in 0..<15 {
            let randomCategory = categories.randomElement()!
            let expense = Expense(
                amount: Double.random(in: 1...100),
                description: descriptions[i],
                date: Calendar.current.date(byAdding: .day, value: -Int.random(in: 0...30), to: Date())!,
                category: randomCategory
            )
            expenses.append(expense)
        }
        
        // Sort by date (newest first)
        expenses.sort { $0.date > $1.date }
    }
    
    func addExpense(_ expense: Expense) {
        expenses.insert(expense, at: 0) // Add to top
    }
    
    func expenses(for category: ExpenseCategory?) -> [Expense] {
        if let category = category {
            return expenses.filter { $0.category == category }
        }
        return expenses
    }
    
    func totalExpenses(for category: ExpenseCategory) -> Double {
        expenses.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }
    
    func totalExpenses() -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func recentExpenses(limit: Int = 5) -> [Expense] {
        Array(expenses.prefix(limit))
    }
}
