import UIKit

class ViewController: UIViewController {

    var objc: ObjCClass
    var swift: SwiftClass
    
    @IBOutlet var aboutSwift: UIButton!
    @IBOutlet var aboutObjC: UIButton!
    
    
    required init?(coder aDecoder: NSCoder) {
        objc = ObjCClass()
        swift = SwiftClass()
        
        objc.swift = self.swift;
        swift.objc = self.objc;
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func moveData() {
    }
    

    @IBAction func titleChange(sender: UIButton) {
    }


    @IBAction func titleChangeObjC(sender: UIButton) {
    }
    

    @IBAction func setupButtonCallbacks() {
    }
    
    
    @IBAction func startObserving() {
    }
    
    
    @IBAction func incrementProgress() {
    } 
    
    
    @IBAction func errorHandling() {
    }
    
    
    @IBAction func swiftError() {
    }
    
}

