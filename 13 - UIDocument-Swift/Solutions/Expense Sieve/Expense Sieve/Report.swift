//
//  Report.swift
//  Expense Sieve
//
//  Created by Michael Ward on 7/7/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class Report: Codable {
    
    // MARK: - Basic state
    
    private(set) var identifier = UUID().uuidString
    private(set) var creationDate = Date()
    var title: String?
    var expenses: [Expense] = []
    var expenseTotal: Double {
        return expenses.map({$0.amount}).reduce(0.0,+)
    }
    var summary: Summary {
        return Summary(report: self)
    }
    
    // MARK: - Summary
    
    struct Summary {
        let identifier: String
        let title: String?
        let expenseTotal: Double
        
        init(report: Report) {
            identifier = report.identifier
            title = report.title
            expenseTotal = report.expenseTotal
        }
    }
}
