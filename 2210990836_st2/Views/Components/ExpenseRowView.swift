//
//  ExpenseRowView.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(expense.description)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(expense.category.rawValue)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(expense.amount, format: .currency(code: "USD"))
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(expense.description), \(expense.amount, format: .currency(code: "USD")), \(expense.category.rawValue), \(expense.date.formatted(date: .abbreviated, time: .omitted))")
    }
}

#Preview {
    ExpenseRowView(expense: Expense(amount: 20.0, description: "Coffee", date: Date(), category: .food))
}
