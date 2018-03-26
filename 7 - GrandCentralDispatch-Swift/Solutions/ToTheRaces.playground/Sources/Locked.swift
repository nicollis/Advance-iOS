import Foundation

public class Locked<Content> {
    
    private let queue = DispatchQueue(label: "Sieverb Resource Lock",
                                      qos: .utility,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .workItem,
                                      target: nil)
    private var content: Content
    
    public init(_ content: Content) {
        self.content = content
    }
    
    public func withReadSafety<Return>(_ workItem: (inout Content) throws -> Return) rethrows -> Return {
        return try queue.sync(execute: { () -> Return in
            return try workItem(&content)
        })
    }
    
    public func withWriteSafety<Return>(_ workItem: (inout Content) throws -> Return) rethrows -> Return {
        return try queue.sync(flags: .barrier, execute: { () -> Return in
            return try workItem(&content)
        })
    }
    
}
