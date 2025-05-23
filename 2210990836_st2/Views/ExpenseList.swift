//
//  ExpenseList.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @Binding var selectedCategory: ExpenseCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedCategory == nil ? "Recent Expenses" : "\(selectedCategory!.rawValue) Expenses\(selectedCategory != nil ? " (Filtered)" : "")")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selectedCategory != nil {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = nil
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                            Text("Clear Filter")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Clear category filter")
                }
            }
            .padding(.horizontal)
            
            let expenses = expenseManager.recentExpenses(limit: 10)
            
            if expenses.isEmpty {
                ContentUnavailableView(
                    "No Expenses",
                    systemImage: "list.bullet",
                    description: selectedCategory == nil
                        ? Text("Add your first expense using the + button.")
                        : Text("No expenses in this category.")
                )
                .frame(height: 150)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(expenses) { expense in
                            ExpenseRowView(expense: expense)
                                .onTapGesture {
                                    print("Selected expense: \(expense.description) - \(expense.amount)")
                                }
                                .padding(.vertical, 4)
                            
                            if expense.id != expenses.last?.id {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    ExpenseListView(selectedCategory: .constant(nil))
        .environmentObject(ExpenseManager())
}
