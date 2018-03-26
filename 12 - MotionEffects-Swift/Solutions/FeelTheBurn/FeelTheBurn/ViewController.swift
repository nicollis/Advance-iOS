//
//  ViewController.swift
//  FeelTheBurn-Swift
//
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var pedometer: CMPedometer?

    @IBOutlet var stepsLabel: UILabel!

    @IBOutlet var startButton: UIButton!
    @IBOutlet var resetButton: UIButton!

    @IBOutlet var fireView: FireView!
    @IBOutlet var stairView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layer.contents = UIImage(named: "graynoise")?.cgImage
        
        let buttonMove = UIInterpolatingMotionEffect(keyPath: "center.x",
                                            type: .tiltAlongHorizontalAxis)
        buttonMove.minimumRelativeValue = -20
        buttonMove.maximumRelativeValue = 20
        startButton.addMotionEffect(buttonMove)
        resetButton.addMotionEffect(buttonMove)
        
        let stairMove = UIInterpolatingMotionEffect(keyPath: "dottedStepIndex",
                                                    type: .tiltAlongVerticalAxis)
        stairMove.minimumRelativeValue = 0
        stairMove.maximumRelativeValue = 12
        stairView.addMotionEffect(stairMove)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetCount(_ sender: UIButton) {
        pedometer?.stopUpdates()
        pedometer = nil
        stepsLabel.text = "No steps"
        fireView.stopBurn()
    }
    
    @IBAction func startCount(_ sender: UIButton) {
        guard CMPedometer.isStepCountingAvailable() else {
            stepsLabel.text = "No Counter!"
            return
        }
        
        pedometer = CMPedometer()
        pedometer?.startUpdates(from: Date()) { (pedometerData, _) in
            OperationQueue.main.addOperation {
                let numberOfSteps = pedometerData?.numberOfSteps.intValue ?? 0
                self.stepsLabel.text = String(format: "%05zd steps", numberOfSteps)
            }
        }
        
        fireView.startBurn()
    }

}
