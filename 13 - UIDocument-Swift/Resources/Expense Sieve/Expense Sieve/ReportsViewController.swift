//
//  ReportsViewController.swift
//  Expense Sieve
//
//  Created by Michael Ward on 7/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ReportsViewController: UITableViewController {
    
    var reports: [Report] = []
    
    let valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @IBAction func handleAddButtonTap(_ sender: UIBarButtonItem) {
        let report = Report()
        reports.insert(report, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {

    }
    
    // MARK: - Transitioning
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let expensesVC = segue.destination as? ExpensesViewController else { return }
        let indexPath = tableView.indexPathForSelectedRow!
        
        expensesVC.report = reports[indexPath.row]
        expensesVC.onDismiss = {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCellID", for: indexPath)
        let report = reports[indexPath.row]
        cell.textLabel?.text = report.title ?? NSLocalizedString("Untitled Report", comment: "Title for new/empty report document")
        let valueText = valueFormatter.string(from: NSNumber(value: report.expenseTotal))
        cell.detailTextLabel?.text = valueText
        return cell
    }

}
