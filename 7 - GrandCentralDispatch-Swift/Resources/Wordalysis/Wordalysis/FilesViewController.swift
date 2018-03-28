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
    var progressGroup = DispatchGroup()
    var timer: DispatchSourceTimer?
    var totalCount: Int {
        let total = counters.map({$0.currentState.totalCount}).reduce(0, +)
        return total
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFileList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdating()
    }
    
    // MARK: - Custom View Lifecycle Methods
    
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
                        strongSelf.progressGroup.enter()
                        counter.start {
                            strongSelf.progressGroup.leave()
                        }
                    }

                    strongSelf.tableView.reloadData()
                    
                    strongSelf.progressGroup.notify(queue: .main) {
                        strongSelf.navigationItem.title = "\(strongSelf.totalCount) Words"
                        strongSelf.presentCompletionAlert()
                    }
                }
            }
        } catch {
            print("[ERR] (\(#file):\(#line)) - \(error)")
        }
    }
    
    func startUpdating() {
        timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer?.schedule(deadline: .now(), repeating: .milliseconds(16), leeway: .microseconds(5))
        timer?.setEventHandler(qos: .userInitiated, flags: [], handler: self.update)
        timer?.resume()
    }
    
    func stopUpdating() {
        timer?.cancel()
        timer = nil
        update()
    }
    
    func update() {
        navigationItem.title = "\(totalCount) words"
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        
        for indexPath in visibleIndexPaths {
            guard let cell = tableView.cellForRow(at: indexPath) else { continue }
            let counter = counters[indexPath.row]
            let count = counter.currentState.totalCount
            cell.textLabel?.text = "\(count)"
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCellID", for: indexPath)
        let counter = counters[indexPath.row]
        cell.textLabel?.text = "\(counter.currentState.totalCount)"
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
