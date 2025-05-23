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
            Image(systemName: iconForCategory(expense.category))
                .font(.title2)
                .foregroundStyle(.blue.gradient)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.system(.headline, design: .rounded, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(expense.date, style: .date)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(expense.amount, format: .currency(code: "USD"))
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(height: 60) // Fixed height to prevent stretching
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Expense: \(expense.description), \(expense.amount, format: .currency(code: "USD")), on \(expense.date, style: .date)")
    }
    
    private func iconForCategory(_ category: ExpenseCategory) -> String {
        switch category {
        case .food: return "fork.knife"
        case .transport: return "car"
        case .utilities: return "bolt"
        case .entertainment: return "film"
        case .other: return "tag"
        }
    }
}

