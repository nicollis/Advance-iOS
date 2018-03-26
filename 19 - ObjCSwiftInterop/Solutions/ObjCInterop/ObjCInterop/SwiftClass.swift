import UIKit

public enum SwiftClassErrorType: Error {
    case domainError
    case recoverableError
    case universalError
}


// @objc(Groot)
public class SwiftClass: NSObject {
    weak var objc: ObjCClass!
    
    static var intValue: Int = {
        print("initializing intValue")
        return 5
    }()
    
    override init() {
        super.init()
        let name = String(cString: class_getName(SwiftClass.self))
        print("I am \(name)")
        print("and intValue is \(SwiftClass.intValue)")
    }
    
    @objc(setIntValue:)
    func setValue(value: Int) {
        print("int value setter \(value)")
    }
    
    @objc(setDoubleValue:)
    func setValue(value: Double) {
        print("double value setter \(value)")
    }
    
    @objc(setVectorValue:)
    func setValue(value: CGVector) {
        print("vector value setter \(value)")
    }

    func addCallback(to button: UIButton) {
        button.addTarget(self,
                         action: #selector(SwiftClass.showAboutBox),
                         for: .touchUpInside)
    }
    
    func showAboutBox() {
        print("pretending to show an about box from Swift")
    }
    
    var progress: Progress?
    var progressObservingContext = 0
    
    func watch(_ progress: Progress) {
        progress.addObserver(self,
                             forKeyPath: #keyPath(Progress.fractionCompleted),
                             options: [ .new, .initial],
                             context: &progressObservingContext)
    }
    

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &progressObservingContext 
            && keyPath == #keyPath(Progress.fractionCompleted) {
            let progressAmount = Float((object as! Progress).fractionCompleted)
            print("progress : \(progressAmount)")
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        progress?.removeObserver(self, forKeyPath: "fractionCompleted")
    }
    
    
    public func errorFunc() throws {
        print("in errorFunc")
        throw SwiftClassErrorType.universalError
    }

}

extension UIButton {
    @objc(bnr_setTheTitle:)
    func setTheTitle(_ title: String) {
        self.setTitle(title, for: .normal)
        
        let sc = SwiftClass()
        print("URGLE \(type(of: sc))")
    }
}


class DynamicClass {
    dynamic func goesThroughObjCRuntime() {
    }
}


