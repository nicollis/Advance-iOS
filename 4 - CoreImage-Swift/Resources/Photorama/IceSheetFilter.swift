//
//  IceSheetFilter.swift
//  Photorama
//
//  Created by Nicholas Ollis on 3/29/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreImage

class IceSheetFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputIntensity: NSNumber?
    
    override func setDefaults() {
        inputIntensity = 0.5
    }
    
    override var outputImage: CIImage? {
        get {
            guard let inputImage = inputImage, let inputIntensity = inputIntensity  else { return nil }
            guard let crystallize = CIFilter(name: "CICrystallize", withInputParameters: [
                kCIInputImageKey: inputImage,
                kCIInputRadiusKey: 100.0 * inputIntensity.floatValue
                ]),
                let crystallizeOutput = crystallize.outputImage else {
                return nil
            }
            
            let bloom = CIFilter(name: "CIBloom", withInputParameters: [
                kCIInputImageKey: crystallizeOutput,
                kCIInputIntensityKey: min(inputIntensity.floatValue / 2 + 0.5, 1),
                kCIInputRadiusKey: inputIntensity.floatValue * 20 + 10
                ])
            
            return bloom?.outputImage
        }
    }
}
