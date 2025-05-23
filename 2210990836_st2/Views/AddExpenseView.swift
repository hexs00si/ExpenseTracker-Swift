//
//  AddExpenseView.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import SwiftUI

/// A SwiftUI view for adding a new expense, presented modally.
struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var expenseManager: ExpenseManager
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var category: ExpenseCategory = .food
    @FocusState private var focusedField: Field?
    
    enum Field {
        case amount
        case description
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { _, newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                let components = filtered.components(separatedBy: ".")
                                amount = components.count > 2 ? components[0] + "." + components.dropFirst().joined() : filtered
                            }
                            .focused($focusedField, equals: .amount)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .accessibilityLabel("Enter expense amount")
                    
                    HStack {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        TextField("What did you spend on?", text: $description)
                            .focused($focusedField, equals: .description)
                    }
                    .accessibilityLabel("Enter expense description")
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .accessibilityLabel("Select expense date")
                    
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        Picker("Category", selection: $category) {
                            ForEach(ExpenseCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .accessibilityLabel("Select expense category")
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .amount
                }
            }
        }
    }
    
    private func saveExpense() {
        let cleanedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Double(cleanedAmount), amountValue > 0, !description.isEmpty else {
            return
        }
        
        let newExpense = Expense(
            amount: amountValue,
            description: description,
            date: date,
            category: category
        )
        
        expenseManager.addExpense(newExpense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseManager())
}
