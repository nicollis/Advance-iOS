//
//  SlideTransition.swift
//  WorldTrotter
//
//  Created by Nicholas Ollis on 3/26/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
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
        //Grab the incoming and outgoing view controllers and views from the context
        let container = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else {
                preconditionFailure("Transition started with missing context info!")
        }
        
        // Take snapshots of both views for the animations
        guard let toSnap = toView.snapshotView(afterScreenUpdates: true),
            let fromSnap = fromView.snapshotView(afterScreenUpdates: true) else {
                return
        }
        
        // Position the outgoing snapshot where the outgoing view is now
        fromSnap.frame = fromView.frame
        toSnap.frame = toView.frame
        
        // Replace the top-level views with their snapshots for the animation
        container.addSubview(toSnap)
        container.addSubview(fromSnap)
        
        fromView.removeFromSuperview()
        
        // Move the toView offscreen and make it smaller
        toSnap.transform = offscreenTransform(for: toSnap, inContainer: container, isReversed: true)
        
        // Define a closure that will actually perform the animation when executed
        let moveViewsClosure = {
            // Move the toView's offscreen-transformed apparence back to where it belongs
            toSnap.transform = .identity
            
            // Transform the fromView's appearance to make it appear offscreen and smaller
            fromSnap.transform = self.offscreenTransform(for: fromSnap, inContainer: container, isReversed: false)
        }
        
        // Define another closer to make the necessary view hierarchy changes
        let cleanUpClosure = { (didComplete: Bool) in
            container.addSubview(toView)
            toSnap.removeFromSuperview()
            fromSnap.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        
        // Kick off the animation
        UIView.animate(withDuration: animationDuration, animations: moveViewsClosure, completion: cleanUpClosure)
    }
    
    // Calculate the correct translation for
    // positiong a view offscreen in a certain direction
    private func offscreenTransform(for view: UIView, inContainer container: UIView, isReversed: Bool) -> CGAffineTransform {
        var transform = view.transform
        switch (animationDirection, isReversed) {
        case (.left, false), (.right, true):
            transform = transform.translatedBy(x: -container.bounds.width, y: 0)
        case (.right, false), (.left, true):
            transform = transform.translatedBy(x: container.bounds.width, y: 0)
        }
        transform = transform.scaledBy(x: 0.875, y: 0.9)
        return transform
    }
    
    
}
