//
//  Expense.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import Foundation

// Used Identifiable so that the enum can be iterated further in the project
// Used String so that .food can be reffered as food


enum ExpenseCategory: String, CaseIterable, Identifiable {
    
    case food = "Food"
    case transport = "Transport"
    case utilities = "Utilities"
    case entertainment = "Entertainment"
    case other = "Other"
    
    
//    Implements the Identifiable protocol by providing a computed id property that returns the enum’s raw value
    var id: String { self.rawValue }
}

struct Expense: Identifiable {
    let id: UUID
    let amount: Double
    let description: String
    let date: Date
    let category: ExpenseCategory
    
    init(id: UUID = UUID(), amount: Double, description: String, date: Date = Date(), category: ExpenseCategory) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.category = category
    }
}
