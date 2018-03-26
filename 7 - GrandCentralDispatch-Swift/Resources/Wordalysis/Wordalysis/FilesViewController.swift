//
//  FilesViewController.swift
//  Sieverb
//
//  Created by Michael Ward on 10/25/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class FilesViewController: UITableViewController {

    let textFinder = TextFinder()
    var counters: [WordCounter] = []
    var totalCount: Int {
        let counts = counters.map { (counter) -> Int in
            let count = counter.totalCount
            return count
        }
        let total = counts.reduce(0,+)
        return total
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFileList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func updateFileList() {
        
        counters.removeAll()
        
        do {
            try textFinder.withTexts { [weak self] (result) in
                guard let strongSelf = self else { return }
                
                switch result {
                    
                case .failure(let error):
                    print("[ERR] (\(#file):\(#line)) - \(error)")
                    
                case .success(let texts):
                    for text in texts {
                        let counter = WordCounter(text: text)
                        strongSelf.counters.append(counter)
                        counter.start()
                    }

                    strongSelf.tableView.reloadData()
                    strongSelf.navigationItem.title = "\(strongSelf.totalCount) Words"
                    strongSelf.presentCompletionAlert()
                }
            }
        } catch {
            print("[ERR] (\(#file):\(#line)) - \(error)")
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCellID", for: indexPath)
        let counter = counters[indexPath.row]
        cell.textLabel?.text = "\(counter.totalCount)"
        cell.detailTextLabel?.text = counter.text.name
        return cell
    }
    
    // MARK: - All Done!
    
    func presentCompletionAlert() {
        let alert = UIAlertController(title: "Analysis Complete",
                                      message: "\(totalCount) words found across \(counters.count) files",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Thanks!", style: .cancel) {[weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
