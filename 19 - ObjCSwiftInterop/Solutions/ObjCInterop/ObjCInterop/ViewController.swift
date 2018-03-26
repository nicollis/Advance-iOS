import UIKit

class ViewController: UIViewController {

    var objc: ObjCClass
    var swift: SwiftClass
    var progress: Progress?
    
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
        let date = Date()
        
        objc.setDate(date)
        objc.setDate(date)
        objc.setDate(date)
        objc.setDate(date)
        
        let bytes: [UInt8] = [0x57, 0x4f, 0x4f, 0x4b, 0x49, 0x45, 0x45];
        let data = Data(bytes: bytes)
        
        objc.setData(data)
        objc.setData(data)
        objc.setData(data)
    }
    
    @IBAction func titleChange(sender: UIButton) {
        sender.setTheTitle("Swift")
    }
    
    @IBAction func titleChangeObjC(sender: UIButton) {
        objc.changeButtonTitle(sender) // this calls `setTheTitle`, renamed bnr_setTheTitle
    }
    
    
    @IBAction func setupButtonCallbacks() {
        swift.addCallback(to: aboutSwift)
        objc.addCallback(to: aboutObjC)
    }
    
    @IBAction func startObserving() {
        guard progress == nil else {
            // disallow multiple concurrent progress objects
            return
        }
        
        progress = Progress(totalUnitCount: 30)
        swift.watch(progress!)
    }
    
    @IBAction func incrementProgress() {
        self.progress?.completedUnitCount += 1
    } 
    
    
    @IBAction func errorHandling() {
        do {
            try objc.mess(withFileSystem: "/", destination: "/snork")
        } catch {
            print("got error: \(error)")
        }
    }
    
    
    @IBAction func swiftError() {
        objc.useSwiftErrorFunc()
    }
    
}

