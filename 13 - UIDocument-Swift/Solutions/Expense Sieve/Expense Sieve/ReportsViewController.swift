//
//  ReportsViewController.swift
//  Expense Sieve
//
//  Created by Michael Ward on 7/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ReportsViewController: UITableViewController {
    
    var summaries: [Report.Summary] = []
    let documentStore = DocumentStore()
    
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
    
        reloadSummaries()
    }
    
    func reloadSummaries() {
        refreshControl?.beginRefreshing()
        documentStore.loadSummaries { (summaries) in
            self.summaries = summaries
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions

    @IBAction func handleAddButtonTap(_ sender: UIBarButtonItem) {
        documentStore.createDocument { (newDocument) in
            self.summaries.insert(newDocument.report.summary, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        reloadSummaries()
    }

    // MARK: - Transitioning
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let expensesVC = segue.destination as? ExpensesViewController else { return }
        let indexPath = tableView.indexPathForSelectedRow!
        
        let identifier = summaries[indexPath.row].identifier
        guard let doc = documentStore.document(forIdentifier: identifier) else { return }
        doc.open {[unowned self] (success) in
            expensesVC.doc = doc
            expensesVC.onDismiss = {
                self.summaries[indexPath.row] = doc.report.summary
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                doc.close(completionHandler: nil)
            }
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCellID", for: indexPath)
        let report = summaries[indexPath.row]
        cell.textLabel?.text = report.title ?? NSLocalizedString("Untitled Report", comment: "Title for new/empty report document")
        let valueText = valueFormatter.string(from: NSNumber(value: report.expenseTotal))
        cell.detailTextLabel?.text = valueText
        return cell
    }

}
