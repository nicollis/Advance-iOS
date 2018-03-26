//
//  FileListViewController.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

class FileListViewController: UITableViewController, GithubClientConsumer {

    var filesToShow = [GithubFile]()
    var githubClient: GithubClient?
    
    // MARK: - Lifecycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let fileVC = segue.destination as? FileViewController {
            fileVC.githubClient = githubClient
            let fileIndexPath = self.tableView?.indexPathForSelectedRow
            if let index = (fileIndexPath as NSIndexPath?)?.row {
                let file = filesToShow[index]
                fileVC.fileToShow = file
            } else {
                print("ERROR: couldn't find gist for fileListVC to show")
            }
        }
    }
    
    // MARK: - Table View Delegate/DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesToShow.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) 
        let file = filesToShow[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = file.fileName
        cell.detailTextLabel?.text = "\(file.size) bytes"
        return cell
    }
    
}
