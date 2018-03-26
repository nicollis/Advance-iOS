import Foundation

@objc enum VisibleEnum: Int {
    case isNegative = -1  // new
    
    case isZero
    case isOne
    case is23 = 23
}


class SwiftClass: NSObject {
    
    weak var objc: ObjCClass!
    
    func useObjC() {
        let objc = ObjCClass()
        objc.printStuffToConsole()
    }
    
    
    func callMe() {
        print("This is Swift code")
    }
    
    func takesOptions(_ options: BitwiseOptions) {
        var names = [String]()
        
        if options == BitwiseOptions() {
            names.append("no options")
        }
        if options.contains(.sortBackwards) {
            names.append("sort backwards")
        }
        if options.contains(.feedTheCat) {
            names.append("feed the cat")
        }
        if options.contains(.useBlinkTag) {
            names.append("use blink tag")
        }
        
        print("got options: \(options) : \(names)")
        
        objc.receiveBitFlags([.sortBackwards, .useBlinkTag])
    }

    func processVisibleEnum(_ visibleEnum: VisibleEnum) {
        print("received visible \(visibleEnum.rawValue)")
    }
    
    func processBareEnum(_ bare: BareEnum) {
        print("received bare \(bare.rawValue)")
        
        if (bare == kThisIsFnord) {
            print("got it")
        }
    }
    
    func processSuitEnum(_ suit: SuitEnum) {
        print("received suit \(suit.rawValue)")
        if suit == .clubs {
            print("got it")
        }
    }
    
    func useStructs() {
        let rect1 = CGRect(x: 10, y: 20, width: 30, height: 40)
        let rect2 = CGRect(x: 100, y: 200, width: 300, height: 400)
        
        let pair = TwoRects(thing1: rect1, thing2: rect2)
        print("First pair: \(pair.thing1) and \(pair.thing2)")
        
        let pair2 = TwoRects()
        print("Second pair \(pair2.thing1) and \(pair2.thing2)")
        
        pair.printThemOut()
    }
    
    func useClosures_theFirstVersion() {
        var array = [ 15, 23, 5, 42, 12, 0, 66, 41 ]
        
        qsort_b(&array, array.count, MemoryLayout<Int>.stride) { (l, r) -> Int32 in
            let left = l!.load(as: Int.self)
            let right = r!.load(as: Int.self)
            
            if left < right { return -1 }
            if left == right { return 0 }
            return 1
        }
        
        print("Sorted integers: \(array)")
    }
    
    func useClosures() {
        var array = [ 15, 23, 5, 42, 12, 0, 66, 41 ]
        
        var counter = 0
        
        func compare(_ l: UnsafeRawPointer?, r: UnsafeRawPointer?) -> Int32 {
            counter += 1  // new
            
            let left = l!.load(as: Int.self)
            let right = r!.load(as: Int.self)
            
            if left < right { return -1 }
            if left == right { return 0 }
            return 1
        }
        
        qsort_b(&array, array.count, MemoryLayout<Int>.stride, compare)
        
        print("it took \(counter) comparisons to sort: \(array)")
    }
    
    func useFunctionPointers() {
        var array = [ 15, 23, 5, 42, 12, 0, 66, 41 ]
        
        // qsort(&array, array.count, MemoryLayout<Int>.stride, compareTwoInts);
        qsort(&array, array.count, MemoryLayout<Int>.stride) { (l, r) -> Int32 in
            let left = l!.load(as: Int.self)
            let right = r!.load(as: Int.self)
            
            if left < right { return -1 }
            if left == right { return 0 }
            return 1
        }
        
        print("after (qsort with function): \(array)")
    }
    
    func printIntPointer(_ intPointer: UnsafePointer<Int>?) {
        if intPointer == nil {
            print("NULL")
        } else {
            print("the value at \(String(describing: intPointer)) is \(String(describing: intPointer?.pointee))")
        }
    }
    
    func writeIntoPointer(_ intPointer: UnsafeMutablePointer<Int>) {
        intPointer.pointee *= 10
    }
    
    func randomAccessPointer(_ intPointer: UnsafeMutablePointer<Int>) {
        print("pointer points to \(intPointer.pointee)")
        let nextIntPointer = intPointer.successor()
        print("next int \(nextIntPointer.pointee)")
        let fifthIntPointer = intPointer.advanced(by: 5)
        print("fifth int \(fifthIntPointer.pointee) which is \(intPointer.distance(to: fifthIntPointer)) away")
        print("sixth int \(intPointer[6])")
        print("seventh int \((intPointer+7).pointee)")
    }
    
    func allocations() {
        let array = UnsafeMutablePointer<Int>.allocate(capacity: 10)
        for i in 0 ..< 10 {
            print("\(array[i])")
        }
        array.deallocate(capacity: 30)
    }
    
    
    func useCString() {
        let string = "This is a Swift string"
        _ = string.withCString { (cptr: UnsafePointer<CChar>) in
            puts(cptr)
        }
    }

    
}



extension TwoRects {
    func printThemOut() {
        print("thing one 1 \(thing1) and thing 2 is \(thing2)")
    }
}

func compareTwoInts(l: UnsafeRawPointer?, r: UnsafeRawPointer?) -> Int32 {
    let left = l!.load(as: Int.self)
    let right = r!.load(as: Int.self)
    
    if left < right { return -1 }
    if left == right { return 0 }
    return 1
}

