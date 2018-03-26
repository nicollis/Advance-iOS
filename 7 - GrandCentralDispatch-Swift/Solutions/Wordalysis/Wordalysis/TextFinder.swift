//
//  FileProcessor.swift
//  Sieverb
//
//  Created by Michael Ward on 9/30/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import MobileCoreServices

fileprivate let docsURL: URL = try! FileManager.default.url(for: .documentDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: false)

struct Text {
    let name: String
    let body: String
}

class TextFinder {
    
    enum Result {
        case success([Text])
        case failure(Swift.Error)
    }
    
    let ioQueue = OperationQueue()
    private static let TextsAlreadyCopiedDefaultsKey = "TextsAlreadyCopiedDefaultsKey"
    
    init() {
        copyTextsIfNeeded()
    }
    
    func copyTextsIfNeeded() {
        let copied = UserDefaults.standard.bool(forKey: TextFinder.TextsAlreadyCopiedDefaultsKey)
        if !copied {
            UserDefaults.standard.set(true, forKey: TextFinder.TextsAlreadyCopiedDefaultsKey)

            let sampleTextNames = ["London Medical Gazette (1828-12-27)",
                                   "Moby Dick",
                                   "Dracula",
                                   "Pride and Prejudice",
                                   "War and Peace",
                                   "War and Peace v2",
                                   "War and Peace v3",
                                   "War and Peace v4",
                                   "War and Peace v5"]
            for name in sampleTextNames {
                guard let sourceURL = Bundle.main.url(forResource: name, withExtension: "txt") else {
                    assertionFailure("[ERR] Unable to get source URL for file \"\(name).txt\"")
                    continue
                }
                let targetURL = docsURL.appendingPathComponent("\(name).txt")
                do {
                    print("Copying \(name)")
                    try FileManager.default.copyItem(at: sourceURL, to: targetURL)
                } catch {
                    assertionFailure("[ERR] Unable to copy \(sourceURL) to \(targetURL)")
                }
            }
        }
    }

    func withTexts(in directory: URL = docsURL,
                   upon userQueue: OperationQueue = OperationQueue.main,
                   execute handler: @escaping (Result) -> Void) throws {
        
        ioQueue.addOperation {
            
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: docsURL,
                                                                       includingPropertiesForKeys: [.isDirectoryKey],
                                                                       options: [.skipsHiddenFiles,
                                                                                 .skipsSubdirectoryDescendants,
                                                                                 .skipsPackageDescendants])
                let textFileURLs = try urls.filter({ (url) -> Bool in
                    let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey,.typeIdentifierKey])
                    let isDir = resourceValues.isDirectory == true
                    let isText = resourceValues.typeIdentifier == kUTTypePlainText as String
                    return !isDir && isText
                })
                
                let texts = try textFileURLs.map({ (url) -> Text in
                    let textBody = try String(contentsOf: url, encoding: String.Encoding.utf8)
                    let textName = url.lastPathComponent.replacingOccurrences(of: ".txt", with: "")
                    return Text(name: textName, body: textBody)
                })
                
                userQueue.addOperation {
                    handler(.success(texts))
                }
                
            } catch {
                userQueue.addOperation {
                    handler(.failure(error))
                }
            }
        }
        
    }
    
}
