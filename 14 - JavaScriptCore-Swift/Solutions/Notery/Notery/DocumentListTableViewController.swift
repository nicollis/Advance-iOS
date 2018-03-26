//
//  DocumentListTableViewController.swift
//  Notery
//
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DocumentListTableViewController: UITableViewController {
    
    var documentViewController: SingleDocumentViewController?
    private let documentStore = DocumentStore()
    private var urls = [URL]()
    
    @IBOutlet var addBarButtonItem: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload), for: .primaryActionTriggered)
        self.refreshControl = refreshControl
        
        startLoading {
            self.addBarButtonItem.isEnabled = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDocument"?:
            guard let indexPath = tableView.indexPathForSelectedRow,
                let documentNavigationController = segue.destination as? UINavigationController,
                let documentViewController = documentNavigationController.topViewController as? SingleDocumentViewController else { return }

            documentViewController.document = Document(fileURL: urls[indexPath.row])
            documentViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            documentViewController.navigationItem.leftItemsSupplementBackButton = true
        default:
            assertionFailure("Unexpected segue")
        }
    }
    
    // MARK: - Actions
    
    private func startLoading(completion: (() -> Void)? = nil) {
        refreshControl?.beginRefreshing()
        documentStore.loadDocuments { (urls) in
            self.urls = urls
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            completion?()
        }
    }
    
    private func requestNewDocumentName(completion: @escaping(String) -> Void) {
        let alert = UIAlertController(title: NSLocalizedString("New Document", comment: "New document name prompt title"),
            message: NSLocalizedString("Choose a name for your new document.", comment: "New document name prompt description"),
            preferredStyle: .alert)
        
        var token: NSObjectProtocol?
        var createAction: UIAlertAction!

        alert.addTextField { (textField: UITextField) in
            textField.autocapitalizationType = .sentences
            
            token = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange,
                object: textField, queue: .main) { (note) in
                let textField = note.object as? UITextField
                createAction.isEnabled = textField?.text?.isEmpty == false
            }
        }
        
        func removeObserver() {
            if let token = token {
                NotificationCenter.default.removeObserver(token)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel",
            comment: "New document name prompt cancel button"), style: .cancel) { _ in
            removeObserver()
        }
        alert.addAction(cancelAction)
        
        createAction = UIAlertAction(title: NSLocalizedString("Create",
            comment: "New document name prompt confirm button"), style: .default) { _ in
            removeObserver()
            
            guard let text = alert.textFields![0].text else {
                preconditionFailure("Alert controller was not set up with a text field")
            }
            completion(text)
        }
        createAction.isEnabled = false
        alert.addAction(createAction)
 
        present(alert, animated: true)

    }
    
    @IBAction private func newDocument(_ sender: Any) {
        requestNewDocumentName { (name) in
            self.documentStore.saveNewDocument(name: name, insertingInto: self.urls) { (url, index) in
                self.urls.insert(url, at: index)
                self.tableView.insertRows(at: [ IndexPath(row: index, section: 0) ], with: .automatic)
            }
        }
    }
    
    @objc private func reload(_ sender: Any) {
        startLoading()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let url = urls[indexPath.row]
        let name = (try? url.resourceValues(forKeys: [ .localizedNameKey ]).localizedName)
        cell.textLabel!.text = name ?? NSLocalizedString("Document", comment: "Fallback name for a document")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.indexPathForSelectedRow != indexPath
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let url = urls.remove(at: indexPath.row)
            documentStore.removeDocument(at: url)
            tableView.deleteRows(at: [ indexPath ], with: .automatic)
        case .none, .insert:
            break
        }
    }

}

// MARK: - Split View

extension DocumentListTableViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryNavigationController = secondaryViewController as? UINavigationController,
            let documentController = secondaryNavigationController.topViewController as? SingleDocumentViewController else { return false }
        return documentController.document == nil
    }
    
}
