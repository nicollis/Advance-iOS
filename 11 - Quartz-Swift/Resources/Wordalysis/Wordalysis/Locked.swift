//
//  Locked.swift
//  Wordalysis
//
//  Created by Michael Ward on 9/30/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class Locked<Content> {
    
    private var content: Content
    private let semaphore = DispatchSemaphore(value: 1)
    
    init(_ content: Content) {
        self.content = content
    }
    
    func withLock<Return>(_ workItem: (inout Content) throws -> Return) rethrows -> Return {
        semaphore.wait()
        let retVal = try workItem(&content)
        semaphore.signal()
        return retVal
    }
}
