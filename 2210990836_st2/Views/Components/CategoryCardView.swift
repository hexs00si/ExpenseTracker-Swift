//
//  CategoryCardView.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import SwiftUI

struct CategoryCardView: View {
    let category: ExpenseCategory
    let amount: Double
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForCategory(category))
                    .font(.title2)
                    .foregroundStyle(.blue.gradient)
                Text(category.rawValue)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            
            Text(amount, format: .currency(code: "USD"))
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120) // Ensure consistent size
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel("\(category.rawValue) category, \(amount, format: .currency(code: "USD"))")
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

#Preview {
    CategoryCardView(category: .food, amount: 50.0, isSelected: false)
        .environmentObject(ExpenseManager())
}
