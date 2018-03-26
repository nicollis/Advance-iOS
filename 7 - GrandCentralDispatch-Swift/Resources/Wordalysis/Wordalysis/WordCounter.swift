//
//  WordCounter.swift
//  AsyncStock
//
//  Created by Michael Ward on 9/30/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class WordCounter: NSObject {
    
    var totalCount = 0
    var wordList: [String:Int] = [:]
    private(set) var text: Text

    init(text: Text) {
        self.text = text
    }
    
    // MARK: - Counting
    
    func start() {
        print("Analyzing \"\(text.name)\"")
        countWords()
        print("Finished  \"\(text.name)\"")
    }
    
    private func countWords() {
        
        let textRange: Range<String.Index> =
            text.body.startIndex..<text.body.endIndex
        
        text.body.enumerateSubstrings(in: textRange, options: .byWords) {
            (substring, subRange, enclosingRange, stop) in
            guard let substring = substring else { return }
            
            if let count = self.wordList[substring] {
                let newCount = count + 1
                self.wordList[substring] = newCount
            } else {
                self.wordList[substring] = 1
            }
            
            self.totalCount += 1
        }
        
    }
}






