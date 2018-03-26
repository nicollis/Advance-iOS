//
//  Expense.swift
//  Expense Sieve
//
//  Created by Michael Ward on 7/7/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import Foundation

class Expense: Codable {
    
    private(set) var photoKey = UUID().uuidString
    var amount = 0.0
    var vendor: String?
    var comment: String?
    var date = Date()

}
