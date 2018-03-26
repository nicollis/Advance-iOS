//
//  ViewController.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

class GistListViewController: UITableViewController, UITextFieldDelegate, GithubClientConsumer {

    @IBOutlet weak var usernameField: UITextField!

    var gistsToShow = [GithubGist]()
    var githubClient: GithubClient?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(GistListViewController.refreshControlPulled(_:)), for: .valueChanged)
        
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usernameField.text = githubClient?.userID
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let fileListVC = segue.destination as? FileListViewController {
            fileListVC.githubClient = githubClient
            let gistIndexPath = self.tableView?.indexPathForSelectedRow
            if let index = (gistIndexPath as NSIndexPath?)?.row {
                let gist = gistsToShow[index]
                fileListVC.filesToShow = gist.files
            } else {
                print("ERROR: couldn't find gist for fileListVC to show")
            }
        }
    }
    
    // MARK: - Table View Delegate / Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gistsToShow.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GistCell", for: indexPath) 
        let gist = gistsToShow[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = gist.userDescription
        cell.detailTextLabel?.text = "\(gist.files.count) file(s)"
        return cell
    }
    
    // MARK: - Actions

    @objc func refreshControlPulled(_ sender: UIRefreshControl) {
        refreshData()
    }
    
    // MARK: - Data Fetching
    
    func refreshData() {
        _ = githubClient?.fetchGistsWithCompletion() { result in
            switch result {
            case .success(let gists):
                DispatchQueue.main.async {
                    self.gistsToShow = gists
                    print("fetched \(gists.count) gists.")
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Couldn't fetch gists: \(error)")
            }
        }
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        githubClient?.userID = textField.text
        textField.resignFirstResponder()
        refreshControl?.beginRefreshing()
        refreshData()
        return true
    }
    
}
