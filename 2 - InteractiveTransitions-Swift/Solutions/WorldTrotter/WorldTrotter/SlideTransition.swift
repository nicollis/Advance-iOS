//
//  SlideTransition.swift
//  WorldTrotter
//
//  Created by Michael L. Ward on 2/6/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

class SlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Direction {
        case left
        case right
    }
    
    var animationDirection = Direction.left
    let animationDuration: TimeInterval = 0.35
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Grab the container and incoming and outgoing views from the context
        let container = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else {
                preconditionFailure("Transition started with missing context info!")
        }
        
        // Take snapshots of both views for the animation
        guard let toSnap = toView.snapshotView(afterScreenUpdates: true),
            let fromSnap = fromView.snapshotView(afterScreenUpdates: true) else {
                return
        }
        
        // Position the outgoing snapshot where the outgoing view is now
        fromSnap.frame = fromView.frame
        toSnap.frame = toView.frame
        
        // Replace the top-level views with their snapshots (just during the animation)
        container.addSubview(toSnap)
        container.addSubview(fromSnap)
        fromView.removeFromSuperview()

        // Make the toView appear to be offscreen and smaller
        toSnap.transform = offscreenTransform(for: toSnap,
                                              inContainer: container,
                                              isReversed: true)

        // Define a closure that will actually perform the animation when executed
        let moveViewsClosure = {
            // Move the toView's offscreen-transformed appearance back to where it belongs
            toSnap.transform = .identity
            
            // Transform the fromView's appearance to make it appear ofscreen and smaller
            fromSnap.transform = self.offscreenTransform(for: fromSnap,
                                                         inContainer: container,
                                                         isReversed: false)
        }

        // Define another closure to reset state post-animation
        let cleanUpClosure = { (didComplete: Bool) in
            let transitionCompleted = didComplete && !transitionContext.transitionWasCancelled
            let endingView = transitionCompleted ? toView : fromView
            container.addSubview(endingView)
            toSnap.removeFromSuperview()
            fromSnap.removeFromSuperview()
            transitionContext.completeTransition(transitionCompleted)
        }
        
        // Kick off the animation
        UIView.animate(withDuration: animationDuration,
                       animations: moveViewsClosure,
                       completion: cleanUpClosure)
    }
    
    // Calculate the correct translation for
    // positioning a view offscreen in a certain direction.
    // Also transform it a bit for fun visual "depth".
    private func offscreenTransform(for view: UIView,
                                    inContainer container: UIView,
                                    isReversed: Bool) -> CGAffineTransform {
        var transform = view.transform
        switch (animationDirection, isReversed) {
        case (.left, false), (.right, true):
            transform = transform.translatedBy(x: -container.bounds.width, y: 0)
        case (.right, false), (.left, true):
            transform = transform.translatedBy(x: container.bounds.width, y: 0)
        }
        
        transform = transform.scaledBy(x: 0.875, y: 0.9) // arbitrary values
        return transform
    }
}
