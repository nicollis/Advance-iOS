//
//  WordCounter.swift
//  AsyncStock
//
//  Created by Michael Ward on 9/30/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class WordCounter: NSObject {
    
    private let counterQueue = DispatchQueue.global(qos: .background)
    
    struct State {
        var totalCount = 0
        var processedCount = 0
        var wordList: [String:Int] = [:]
        var processing = false
    }
    private var lockedState = Locked(State())
    private(set) var text: Text
    
    var currentState: State {
        return lockedState.withLock({ $0 })
    }
    
    var runSlowly = false

    struct TextStats {
        var title = ""
        var processing = false
        var totalCount = 0
        var processedCount = 0
        var processedPercentage = 0.0
        var mostPopularWord: (word: String, count: Int) = ("", 0)
        var longestMostPopularWord: (word: String, count: Int) = ("", 0)
        var wordFrequencyHistogram: [Int: Int] = [:]
    }
    var currentTextStats: TextStats {
        let statsSnapshot = currentState  // copy state under lock

        let textStats = calculateStats(fromState: statsSnapshot)
        
        return textStats
    }
    
    private func shouldUseWord(_ word: String) -> Bool {
        if word.hasPrefix("www.") { return false }
        if word.hasPrefix("http") { return false }
        
        return true
    }
    
    private func calculateStats(fromState state: State) -> TextStats {
        var stats = TextStats()
        stats.title = text.name
        stats.processing = state.processing
        stats.totalCount = state.totalCount
        stats.processedCount = state.processedCount
        stats.processedPercentage = Double(state.processedCount) / Double(state.totalCount)
        
        var mostPopularWord: (word: String, count: Int) = ("", 0)
        var longestMostPopularWord: (word: String, count: Int) = ("", 0)
        
        for (rawWord, count) in state.wordList {
            let word = rawWord.lowercased()
            guard shouldUseWord(word) else { continue }
            if count > mostPopularWord.count {
                mostPopularWord = (word, count)
            }
            let wordLength = word.count
            let longPopWordCount = longestMostPopularWord.word.count
            
            if wordLength > longestMostPopularWord.word.count {
                longestMostPopularWord = (word, count)
            } else if wordLength == longPopWordCount && count > longestMostPopularWord.count {
                mostPopularWord = (word, count)
            }

            // tracks the number of unique words of this length
            let histogramCount = stats.wordFrequencyHistogram[wordLength] ?? 0
            stats.wordFrequencyHistogram[wordLength] = histogramCount + 1
        }

        stats.mostPopularWord = mostPopularWord
        stats.longestMostPopularWord = longestMostPopularWord
        
        var blah = 0
        for (_, value) in stats.wordFrequencyHistogram {
            blah += value
        }
        
        return stats
    }
    

    init(text: Text) {
        self.text = text
    }
    
    // MARK: - Counting
    func start(completion: @escaping ()->Void) {
        print("Analyzing \"\(text.name)\"")
        counterQueue.async {
            self.countWords()
            print("Finished  \"\(self.text.name)\"")
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func reset() {
        lockedState = Locked(State())
    }
    
    private func countWords() {
        let textRange: Range<String.Index> =
            text.body.startIndex..<text.body.endIndex

        self.lockedState.withLock { state in
            var totalCount = 0
            text.body.enumerateSubstrings(in: textRange, options: .byWords) { (substring, _, _, _) in
                guard let _ = substring else { return }
                totalCount += 1
            }
            state.totalCount = totalCount
            state.processing = true
        }

        text.body.enumerateSubstrings(in: textRange, options: .byWords) {
            (substring, subRange, enclosingRange, stop) in

            guard let substring = substring else { return }
            
            self.lockedState.withLock({ state in
                if self.runSlowly {
                    usleep(2)
                }
                
                if let count = state.wordList[substring] {
                    let newCount = count + 1
                    state.wordList[substring] = newCount
                } else {
                    state.wordList[substring] = 1
                }
                
                state.processedCount += 1
            })
        }

        self.lockedState.withLock { state in
            state.processing = false
        }
    }
}






