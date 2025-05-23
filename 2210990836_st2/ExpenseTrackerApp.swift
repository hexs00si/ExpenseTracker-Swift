//
//  _210990836_st2App.swift
//  2210990836_st2
//
//  Created by Shravan Rajput on 23/05/25.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @StateObject private var expenseManager = ExpenseManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardViewControllerRepresentable(expenseManager: expenseManager)
                .ignoresSafeArea()
        }
    }
}

struct DashboardViewControllerRepresentable: UIViewControllerRepresentable {
    let expenseManager: ExpenseManager
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let dashboardVC = DashboardViewController(expenseManager: expenseManager)
        return UINavigationController(rootViewController: dashboardVC)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}
