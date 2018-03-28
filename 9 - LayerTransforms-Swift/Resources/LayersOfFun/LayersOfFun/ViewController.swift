import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var imageView: UIView!
    @IBOutlet var topPin: NSLayoutConstraint!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        let layer = imageView.layer
        let anim = CAKeyframeAnimation(keyPath: "transform")
        
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0/1000.0
        layer.transform = perspective
        
        let txform = layer.transform
        let angle = CGFloat(Float.pi)
        let rotTxform = CATransform3DRotate(txform, angle, 0.0, 1.0, 0.0)
        let rotAndMoveLeft = CATransform3DTranslate(rotTxform, 0.0, 0.0, -100.0)
        let rotAndMoveRight = CATransform3DTranslate(rotTxform, 0.0, 0.0, 100.0)

        
        anim.values = [txform, rotTxform, rotAndMoveLeft, rotAndMoveRight, txform, txform]
        anim.duration = 2.0
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        anim.autoreverses = true
        anim.repeatCount = .infinity
        layer.add(anim, forKey: "spin")
        layer.transform = rotTxform
        
    }
    
    
}
