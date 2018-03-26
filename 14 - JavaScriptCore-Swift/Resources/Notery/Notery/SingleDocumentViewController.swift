//
//  SingleDocumentViewController.swift
//  Notery
//
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class SingleDocumentViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var textView: UITextView!
    
    var document: Document? {
        willSet {
            closeDocument()
        }
        didSet {
            openDocument()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let document = document {
            configureTextView(with: document)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.flashScrollIndicators()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // copy the text from the view into the document
        if let document = document {
            document.contents = textView.text
            document.save(to: document.fileURL, for: .forOverwriting)
        }
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Actions
    
    private func clearTextView() {
        guard isViewLoaded else { return }
        
        textView.text = nil
        textView.isEditable = false
        textView.undoManager?.removeAllActions()
    }
    
    private func configureTextView(with document: Document) {
        guard isViewLoaded, self.document === document else { return }
        
        textView.text = document.contents
        textView.isEditable = true
        document.undoManager = textView.undoManager
    }
    
    private func openDocument() {
        guard let document = document else { return }
        
        let name = (try? document.fileURL.resourceValues(forKeys: [ .localizedNameKey ]))?.localizedName
        self.title = name ?? NSLocalizedString("Document", comment: "Fallback name for a document")
        
        clearTextView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(noteDocumentStateChanged),
                                               name: .UIDocumentStateChanged, object: document)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(noteDocumentDidUpdate),
                                               name: Document.contentsDidUpdateNotification,
                                               object: document)
        
        document.open { _ in
            self.configureTextView(with: document)
        }
    }
    
    private func closeDocument() {
        guard let document = document else { return }
        
        document.undoManager = nil
        document.close()
        
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIDocumentStateChanged, object: document)
        NotificationCenter.default.removeObserver(self,
                                                  name: Document.contentsDidUpdateNotification,
                                                  object: document)
    }
    
    // MARK: - Notifications
    
    @objc func noteDocumentStateChanged(_ note: Notification) {
        guard let document = note.object as? Document, document === self.document else { return }
        
        textView.isEditable = document.documentState.contains(.editingDisabled)
        
        if document.documentState.contains(.inConflict) {
            // This application uses a basic newest version wins conflict resolution strategy
            let conflictVersions = NSFileVersion.unresolvedConflictVersionsOfItem(at: document.fileURL) ?? []
            for fileVersion in conflictVersions {
                fileVersion.isResolved = true
            }
            try! NSFileVersion.removeOtherVersionsOfItem(at: document.fileURL)
        }
        
    }
    
    @objc func noteDocumentDidUpdate(_ note: Notification) {
        guard let document = note.object as? Document, document === self.document else { return }
        
        configureTextView(with: document)
    }
    
}
