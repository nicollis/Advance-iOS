//
//  ViewController.swift
//  FeelTheBurn-Swift
//
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var stepsLabel: UILabel!

    @IBOutlet var startButton: UIButton!
    @IBOutlet var resetButton: UIButton!

    @IBOutlet var fireView: UIView!
    @IBOutlet var stairView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
