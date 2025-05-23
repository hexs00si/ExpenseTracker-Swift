//
//  CategoryGridView.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import SwiftUI

struct CategoryGridView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @Binding var selectedCategory: ExpenseCategory?
    
    var columns: [GridItem] {
        let isLandscape = UIDevice.current.orientation.isLandscape
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let columnCount = isIPad ? 4 : isLandscape ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses by Category")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ExpenseCategory.allCases) { category in
                        CategoryCardView(
                            category: category,
                            amount: expenseManager.totalExpenses(for: category),
                            isSelected: selectedCategory == category
                        )
                        .frame(minHeight: 120) // Ensure consistent height
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = (selectedCategory == category) ? nil : category
                            }
                        }
                        .scaleEffect(selectedCategory == category ? 1.05 : 1.0)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    CategoryGridView(selectedCategory: .constant(nil))
        .environmentObject(ExpenseManager())
}
