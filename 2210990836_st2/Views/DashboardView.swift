import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @State private var selectedCategory: ExpenseCategory?
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Total Expenses Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total: \(expenseManager.totalExpenses(), format: .currency(code: "USD"))")
                            .font(.system(.title2, design: .rounded, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    
                    // Bar Chart
                    ChartView()
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                        .transition(.opacity)
                    
                    // Category Grid
                    CategoryGridView(selectedCategory: $selectedCategory)
                        .transition(.move(edge: .bottom))
                    
                    // Recent Expenses List
                    ExpenseListView(selectedCategory: $selectedCategory)
                        .transition(.move(edge: .bottom))
                }
                .padding(.vertical)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedCategory)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Expense Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue.gradient)
                    }
                    .accessibilityLabel("Add new expense")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
                    .environmentObject(expenseManager)
            }
        }
    }
}

struct ChartView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    
    struct ChartData: Identifiable {
        let id = UUID()
        let category: ExpenseCategory
        let amount: Double
    }
    
    var body: some View {
        let data = ExpenseCategory.allCases.map { category in
            ChartData(category: category, amount: expenseManager.totalExpenses(for: category))
        }
        
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Category", item.category.rawValue),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(.blue.gradient)
                .cornerRadius(8)
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .stride(by: 1)) { value in
                if value.index % 2 == 0 { // Show every other label
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.primary)
                        .offset(y: 5) // Slight offset to avoid overlap
                }
                AxisGridLine()
                AxisTick()
            }
        }
        .chartYAxis {
            AxisMarks(format: .currency(code: "USD").precision(.fractionLength(0)))
        }
        .frame(height: 200)
        .padding()
        .padding(.bottom, 10) // Adjusted padding for labels
        .accessibilityLabel("Bar chart showing expenses by category")
    }
}

#Preview {
    DashboardView()
        .environmentObject(ExpenseManager())
}
