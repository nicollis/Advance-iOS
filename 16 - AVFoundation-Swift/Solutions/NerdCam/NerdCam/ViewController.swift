//
//  ViewController.swift
//  NerdCam
//
//  Created by Michael Ward on 9/19/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CodeReaderDelegate {
    
    let reader = CodeReader()
    let talker = Talker()
    var preview: CALayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR = UITapGestureRecognizer(target: self,
                                           action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tapGR)
        
        reader.delegate = self
        startScanning()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        startScanning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startScanning() {
        // Tear down any existing preview
        preview?.removeFromSuperlayer()
        reader.stop()
        
        // Start scanning for codes
        guard reader.start() else {
            print("\(#function): Failed to start CodeReader")
            return
        }
        
        // Install the preview in the layer hierarchy
        preview = reader.previewLayer
        preview!.frame = view.layer.bounds
        view.layer.addSublayer(preview!)
    }
    
    func codeReader(_ reader: CodeReader, didReadCode code: String) {
        print("CodeReader read: \(code)")
        reader.stop()
        talker.say(code)
    }

}

