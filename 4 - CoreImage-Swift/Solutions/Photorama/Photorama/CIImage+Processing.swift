//
//  CIImage+Processing.swift
//  Photorama
//
//  Created by Michael Ward on 9/14/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

extension CIImage {
    
    func scaled(toFit maxSize: CGSize) -> CIImage {
        let aspectRatio = extent.width / extent.height
        let scale: CGFloat
        
        // Make sure we scale based on the long axis
        if aspectRatio > 1.0 {
            scale = maxSize.width / extent.width
        } else {
            scale = maxSize.height / extent.height
        }
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        let outputImage = transformed(by: scaleTransform)
        return outputImage
    }
    
    func pixellatedFaces(using context: CIContext) -> CIImage {
        let features = faceFeatures(using: context)
        if features.isEmpty {
            return self
        }
        
        let resultImage = features.reduce(self) { inputImage, face in
            let faceImage = self.cropped(to: face.bounds)
            let pixellatedFaceImage = faceImage.pixellated()
            let compositedFaceImage = pixellatedFaceImage.composited(over: inputImage)
            return compositedFaceImage
        }
        
        return resultImage
    }
    
    func filtered(_ filter: ImageProcessor.Filter) throws -> CIImage {
        let parameters: [String: AnyObject]
        let filterName: String
        let shouldCrop: Bool
        
        // Configure the CIFilter() inputs based on the chosen filter
        switch filter {
            
        case .none:
            return self
            
        case .gloom(let intensity, let radius):
            parameters =
                [ kCIInputImageKey: self,
                  kCIInputIntensityKey: NSNumber(value: intensity),
                  kCIInputRadiusKey: NSNumber(value: radius) ]
            filterName = "CIGloom"
            shouldCrop = true
            
        case .sepia(let intensity):
            parameters =
                [ kCIInputImageKey: self,
                  kCIInputIntensityKey: NSNumber(value: intensity) ]
            filterName = "CISepiaTone"
            shouldCrop = false
            
        case .blur(let radius):
            parameters =
                [ kCIInputImageKey: self,
                  kCIInputRadiusKey: NSNumber(value: radius) ]
            filterName = "CIGaussianBlur"
            shouldCrop = true
        }
        
        // Actually create and apply the filter
        guard let filter = CIFilter(name: filterName, withInputParameters: parameters),
              let output = filter.outputImage else {
                throw ImageProcessor.Error.filterConfiguration(name: filterName,
                                                               params: parameters)
        }
        
        // Crop back to extent if necessary
        if shouldCrop {
            let croppedImage = output.cropped(to: extent)
            return croppedImage
        } else {
            return output
        }
    }
    
    // MARK: - Helpers
    
    func faceFeatures(using context: CIContext) -> [CIFaceFeature] {
        let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                                      context: context,
                                      options: detectorOptions)!
        let features = faceDetector.features(in: self) as! [CIFaceFeature]
        
        return features
    }
    
    func pixellated() -> CIImage {
        let inputParams: [String:AnyObject] = [ kCIInputImageKey: self,
                                                kCIInputScaleKey: NSNumber(value: 45.0),
                                                kCIInputCenterKey: CIVector(x: 0, y: 0) ]
        
        guard let filter = CIFilter(name: "CIPixellate", withInputParameters: inputParams),
              let output = filter.outputImage else {
                fatalError("CIImage.pixellated() failed to configure its filter.")
        }
        
        return output
    }
    
}
