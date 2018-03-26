//
//  DatePickerViewController.swift
//  Expense Sieve
//
//  Created by Michael Ward on 8/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!

    var onDismiss: (()->Void)? {
        willSet {
            assert(onDismiss == nil, "onDismiss is already set!")
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed || isMovingFromParentViewController {
            onDismiss?()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleTodayButtonTap(_ sender: UIBarButtonItem) {
        datePicker.date = Date()
    }
    
}
