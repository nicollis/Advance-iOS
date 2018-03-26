//
//  Document.swift
//  Expense Sieve
//
//  Created by Michael Ward on 8/31/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class Document: UIDocument, ImageCache {
    
    // MARK: - Scoped types
    
    enum Error: Swift.Error {
        case unexpectedContents
    }
    
    // MARK: - Properties
    
    lazy var report = Report()
    private lazy var packageWrapper = FileWrapper(directoryWithFileWrappers: [:])
    static let reportFilename = "report.archive"
    
    // MARK: - Document saving/loading
    
    override func contents(forType typeName: String) throws -> Any {
        
        let encoder = JSONEncoder()
        let reportData = try encoder.encode(report)
        
        // remove the report.archive before adding it to prevent duplicate fileWrappers being created
        if let fileWrapper = packageWrapper.fileWrappers?["report.archive"] {
            packageWrapper.removeFileWrapper(fileWrapper)
        }
        
        packageWrapper.addRegularFile(withContents: reportData, preferredFilename: Document.reportFilename)
        
        return packageWrapper
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        guard let packageWrapper = contents as? FileWrapper,
              let reportWrapper = packageWrapper.fileWrappers?[Document.reportFilename],
              let reportData = reportWrapper.regularFileContents else {
            throw Error.unexpectedContents
        }
        let decoder = JSONDecoder()
        let report = try decoder.decode(Report.self, from: reportData)
        self.packageWrapper = packageWrapper
        self.report = report
    }
    
    // MARK: - Image Cache
    
    private let imageCache = NSCache<NSString,UIImage>()
    
    func image(forKey key: String) -> UIImage? {
        // First, check the NSCache
        if let image = imageCache.object(forKey: key as NSString) {
            return image
        }
        
        // If it's not there or has been purged, check the disk
        if let imageData = packageWrapper.fileWrappers?[key]?.regularFileContents,
           let image = UIImage(data: imageData) {
            return image
        }
        
        return nil
    }
    
    func set(_ image: UIImage?, forKey imageID: String) {
        // If there's currently an image for the current key, nuke it
        if let oldImageWrapper = packageWrapper.fileWrappers?[imageID] {
            packageWrapper.removeFileWrapper(oldImageWrapper)
        }
        
        // If we have a new image, wrap and add it
        if let image = image {
            imageCache.setObject(image, forKey: imageID as NSString)
            
            let imageData = UIImagePNGRepresentation(image)!
            packageWrapper.addRegularFile(withContents: imageData, preferredFilename: imageID)
            
        } else {
            imageCache.removeObject(forKey: imageID as NSString)
        }
    }

}
