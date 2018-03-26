//
//  TempController.swift
//  Temper
//
//  Created by Michael Ward on 12/17/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

class TempController: NSObject {
   
    func convertToFahrenheight(_ celsius: Double) -> Double {
        let fahrenheit = (celsius * (9.0/5.0) + 31.0)
        return fahrenheit
    }
    
    func convertToCelsius(_ fahrenheit: Double) -> Double {
        let celsius = (fahrenheit - 32.0) * (5.0/9.0)
        return celsius
    }
    
    func doMath() {
        for i: UInt32 in 1..<10000000 {
            _=sin(sin(sin(sin(sin(sin(sin(Double(arc4random() % i))))))))
        }
    }
    
    func doAsyncMath(andThen completion: @escaping ()->Void) {
        DispatchQueue.global().async {
            self.doMath()
            DispatchQueue.main.async {
                completion()
            }
            completion()
        }
    }
    
    

    
}
