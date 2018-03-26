//
//  Document.swift
//  Notery
//
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import MobileCoreServices

class Document: UIDocument {
    
    enum Error: Swift.Error {
        case invalidFileType
        case invalidFileFormat
    }
    
    var contents = NSLocalizedString("New Document", comment: "Default text for a new document")
    
    private func isValidTypeName(_ typeName: String) -> Bool {
        return UTTypeConformsTo(typeName as CFString, Document.typeIdentifier as CFString)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let typeName = typeName, isValidTypeName(typeName) else {
            throw Error.invalidFileType
        }
        
        guard let data = contents as? Data, let contents = String(data: data, encoding: .utf8) else {
            throw Error.invalidFileFormat
        }
        
        self.contents = contents
        
        NotificationCenter.default.post(name: Document.contentsDidUpdateNotification, object: self)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        guard isValidTypeName(typeName) else {
            throw Error.invalidFileType
        }
        
        return contents.data(using: .utf8) ?? Data()
    }
    
}

extension Document {
    
    static let contentsDidUpdateNotification = Notification.Name(rawValue: "NoteryDocumentContentsDidUpdate")
    static let typeIdentifier = "com.bignerdranch.advios.Notery.document"
    static let preferredExtension = "noteryDoc"
    
}
