//
//  ImageProcessingOperation.swift
//  Photorama
//
//  Created by Michael Ward on 9/15/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ImageProcessingOperation: Operation {
    
    var image: UIImage?
    let actions: [ImageProcessor.Action]
    let completion: ImageProcessor.ResultHandler
    
    init(image: UIImage, actions: [ImageProcessor.Action],
         priority: ImageProcessor.Priority = .low,
         completion: @escaping ImageProcessor.ResultHandler) {
        self.image = image
        self.actions = actions
        self.completion = completion
        super.init()
        
        switch priority {
        case .high:
            qualityOfService = .userInitiated
            queuePriority = .high
        case .low:
            qualityOfService = .utility
            queuePriority = .low
        }
    }
    
    convenience init(operation: ImageProcessingOperation,
                     priority: ImageProcessor.Priority = .low) {
        
        guard let image = operation.image else {
            preconditionFailure("FATAL: Attempt to clone an operation with nil image")
        }
        
        self.init(image: image,
                  actions: operation.actions,
                  priority: priority,
                  completion: operation.completion)
    }
    
    override func main() {
        
        guard let image = image else {
            completion(.cancelled)
            return
        }
        
        do {
            let processedImage = try perform(actions, on: image)
            completion(.success(processedImage))
        } catch ImageProcessor.Error.cancelled {
            completion(.cancelled)
        } catch {
            completion(.failure(error))
        }
    }
    
    override func cancel() {
        super.cancel()
        image = nil
    }
    
    func perform(_ actions: [ImageProcessor.Action], on image: UIImage) throws -> UIImage {
        
        guard !isCancelled else { throw ImageProcessor.Error.cancelled }
        
        // Set up the CIImage and context
        guard var workingImage = CIImage(image: image) else {
            throw ImageProcessor.Error.incompatibleImage
        }
        let context = CIContext(options: nil)
        
        // Apply requested processing
        for action in actions {
            
            guard !isCancelled else { throw ImageProcessor.Error.cancelled }
            
            switch action {
            case .pixellateFaces:
                workingImage = workingImage.pixellatedFaces(using: context)
            case .scale(let maxSize):
                workingImage = workingImage.scaled(toFit: maxSize)
            case .filter(let filter):
                workingImage = try workingImage.filtered(filter)
            }
        }
        
        // Extract the resultant UIImage and handle it
        let renderedImage = context.createCGImage(workingImage,
                                                  from: workingImage.extent)!
        let resultImage = UIImage(cgImage: renderedImage)
        
        guard !isCancelled else { throw ImageProcessor.Error.cancelled }
        
        return resultImage
    }
    
}
