//
//  HazeRemoveFilter.swift
//  Photorama
//
//  Created by Nicholas Ollis on 3/27/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreImage

class HazeRemoveFilter: CIFilter {
    var inputImage: CIImage?
    var inputColor: CIColor?
    var inputDistance: NSNumber?
    var inputSlope: NSNumber?
    
    private(set) static var hazeRemovalKernal: CIKernel? = {
            guard let className = NSClassFromString("HazeRemoveFilter") else { fatalError("Failed to find class name of HazeRemoveFilter") }
            let bundle = Bundle(for: className)
            guard let code = bundle.path(forResource: "HazeRemove", ofType: "cikernel") else { fatalError("Failed to load HazeRemove.cikernel from bundle") }
            let kernel = CIColorKernel(source: code)
            return kernel
    }()
    
//    override var outputImage: CIImage? {
//        get {
//            if let inputImage = self.inputImage {
//                let args = [inputImage as AnyObject]
//                return createCustomKernel().apply(withExtent: inputImage.extent, arguments: args)
//            } else {
//                return nil
//            }
//        }
//    }
}
