//
//  ViewController.swift
//  Temper
//
//  Created by Michael Ward on 12/17/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var celsiusField: UITextField!
    @IBOutlet weak var fahrenheitField: UITextField!
    
    let tempController = TempController()
    
    var foo: String = "hello"
    
    override func viewWillAppear(_ animated: Bool) {
        foo = "hello"
        print("View appearing!")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View disappearing!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        celsiusField.delegate = self
        fahrenheitField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case celsiusField:
            let c = NSString(string: celsiusField.text!).doubleValue
            let f = tempController.convertToFahrenheight(c)
            fahrenheitField.text = NSNumber(value: f as Double).stringValue
        case fahrenheitField:
            let f = NSString(string: fahrenheitField.text!).doubleValue
            let c = tempController.convertToCelsius(f)
            celsiusField.text = NSNumber(value: c as Double).stringValue
        default:
            print("You done screwed up, son.")
        }
        
        textField.resignFirstResponder()
        return true
    }

}

