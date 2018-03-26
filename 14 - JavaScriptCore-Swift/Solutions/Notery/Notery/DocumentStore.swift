//
//  DocumentStore.swift
//  Notery
//
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import Foundation
import MobileCoreServices

class DocumentStore {
    
    // MARK: - Properties
    
    private let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    // MARK: - Managing Documents

    private func compare(lhs: URL, rhs: URL) -> ComparisonResult {
        return lhs.lastPathComponent.localizedStandardCompare(rhs.lastPathComponent)
    }
    
    func loadDocuments(completion: @escaping ([URL]) -> Void) {
        DispatchQueue.global().async {
            var foundURLs = [URL]()
            
            defer {
                foundURLs.sort { (lhs, rhs) in
                    self.compare(lhs: lhs, rhs: rhs) == .orderedAscending
                }
                
                DispatchQueue.main.async {
                    completion(foundURLs)
                }
            }
            
            guard let urls = try? FileManager.default.contentsOfDirectory(at: self.documentsDirectory, includingPropertiesForKeys: [ .documentIdentifierKey, .typeIdentifierKey ]) else { return }
            
            foundURLs = urls.filter { (url) in
                guard let values = try? url.resourceValues(forKeys: [ .typeIdentifierKey ]), let uti = values.typeIdentifier else { return false }
                return UTTypeConformsTo(uti as CFString, Document.typeIdentifier as CFString)
            }
        }
    }
    
    func saveNewDocument(name: String, insertingInto existingDocuments: [URL], completion: @escaping (URL, Int) -> Void) {
        // Create a new document
        let url = documentsDirectory.appendingPathComponent(name).appendingPathExtension(Document.preferredExtension)
        let document = Document(fileURL: url)
        
        let insertionIndex = (existingDocuments as NSArray).index(of: url, inSortedRange: NSRange(0 ..< existingDocuments.count), options: .insertionIndex) { (lhs, rhs) in
            guard let lhs = lhs as? URL, let rhs = rhs as? URL else { return .orderedAscending }
            return compare(lhs: lhs, rhs: rhs)
        }
        
        // Give the newly-created document an on-disk representation
        document.save(to: url, for: .forCreating) { (success) in
            guard success else {
                assertionFailure("Failed to create new document at \(url)")
                return
            }
            completion(url, insertionIndex)
        }
    }
    
    func removeDocument(at url: URL) {
        DispatchQueue.global().async {
            let coordinator = NSFileCoordinator()
            coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil) { (url) in
                _ = try? FileManager().removeItem(at: url)
            }
        }
    }

}
