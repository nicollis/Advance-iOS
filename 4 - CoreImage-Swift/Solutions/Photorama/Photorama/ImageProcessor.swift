//
//  ImageProcessor.swift
//  Photorama
//
//  Created by Michael Ward on 9/14/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ImageProcessor {
    
    enum Action {
        case scale(maxSize: CGSize)
        case pixellateFaces
        case filter(Filter)
    }
    
    enum Filter {
        case none
        case gloom(intensity: Double, radius: Double)
        case sepia(intensity: Double)
        case blur(radius: Double)
    }
    
    enum Error: Swift.Error {
        case incompatibleImage
        case filterConfiguration(name: String, params: [String:AnyObject]?)
    }
    
    func perform(_ actions: [Action], on image: UIImage) throws -> UIImage {
    
        // Set up the CIImage and context
        guard var workingImage = CIImage(image: image) else {
            throw Error.incompatibleImage
        }
        let context = CIContext(options: nil)
        
        // Apply requested processing
        for action in actions {
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
        return resultImage
    }
}
