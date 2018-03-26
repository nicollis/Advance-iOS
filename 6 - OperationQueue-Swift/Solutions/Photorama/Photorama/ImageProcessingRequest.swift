//
//  ImageProcessingRequest.swift
//  Photorama
//
//  Created by Michael Ward on 9/16/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ImageProcessingRequest {
    private var operation: ImageProcessingOperation
    private let queue: OperationQueue
    
    var priority: ImageProcessor.Priority = .low {
        didSet(oldPriority) {
            guard priority != oldPriority else { return }
            guard !operation.isExecuting else { return }
            let newOp = ImageProcessingOperation(operation: operation, priority: priority)
            operation.cancel()
            operation = newOp
            queue.addOperation(newOp)
        }
    }
    
    init(operation: ImageProcessingOperation, queue: OperationQueue) {
        self.operation = operation
        self.queue = queue
    }
    
    func cancel() {
        operation.cancel()
    }
}
