//: Playground - noun: a place where people can play

import UIKit

// Allow the playground to run long enough to finish the async work
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let queue = DispatchQueue(label: "queue1",qos: .utility)
let queue2 = DispatchQueue(label: "queue2",qos: .userInitiated)

var lockedBalance = Locked(0)

for i in 1...10_000 {
    DispatchQueue.global().async {
        lockedBalance.withWriteSafety { balance in
            let b = balance
            balance = b + i
        }
    }

    DispatchQueue.global().async {
        lockedBalance.withWriteSafety { balance in
            let b = balance
            balance = b - i
        }
    }
}

lockedBalance.withReadSafety { balance in
    balance
}
