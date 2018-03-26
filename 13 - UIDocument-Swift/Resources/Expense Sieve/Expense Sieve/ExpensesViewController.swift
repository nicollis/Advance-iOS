//
//  ExpensesViewController.swift
//  Expense Sieve
//
//  Created by Michael Ward on 8/4/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ExpensesViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var titleField: UITextField!

    var report: Report!
    var imageCache = ImageCache()

    let valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var onDismiss: (()->Void)? {
        willSet {
            assert(onDismiss == nil, "onDismiss is already set!")
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.text = report.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed || isMovingFromParentViewController {
            titleField.endEditing(true)
            onDismiss?()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleAddButtonTap(_ sender: UIBarButtonItem) {
        let expense = Expense()
        report.expenses.insert(expense, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Transitioning
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? ExpenseDetailViewController else { return }
        let indexPath = tableView.indexPathForSelectedRow!
        
        detailVC.currentExpense = report.expenses[indexPath.row]
        detailVC.imageCache = imageCache
        detailVC.onDismiss = {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return report.expenses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCellID", for: indexPath)
        let expense = report.expenses[indexPath.row]
        cell.textLabel?.text = expense.vendor ?? NSLocalizedString("Unknown Vendor", comment: "")
        let valueText = valueFormatter.string(from: NSNumber(value: expense.amount))
        cell.detailTextLabel?.text = valueText
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        report.title = titleField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
