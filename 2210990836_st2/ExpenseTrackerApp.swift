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
            DashboardView()
                .environmentObject(expenseManager)
        }
    }
}
