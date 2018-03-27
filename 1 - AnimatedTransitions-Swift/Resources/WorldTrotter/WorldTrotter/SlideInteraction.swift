//
//  SlideInteraction.swift
//  WorldTrotter
//
//  Created by Nicholas Ollis on 3/26/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

class SlideInteraction: UIPercentDrivenInteractiveTransition {
    
    var tabBarController: UITabBarController?
    var currentlyInteractive = false
    
    @objc func handlePan(_ gr: UIScreenEdgePanGestureRecognizer) {
        guard let tabBarController = tabBarController else {
            print("TabBarController nil in SlideInteraction!")
            return
        }
        print("Panned to relative location: \(gr.translation(in: nil))")
        
        let dX = gr.translation(in: tabBarController.view).x
        let tabCount = tabBarController.viewControllers!.count
        let selectedIndex = tabBarController.selectedIndex
        
        switch gr.state {
        case .began:
            currentlyInteractive = true
            if dX > 0 && selectedIndex > 0 {
                tabBarController.selectedIndex -= 1
            } else if dX <= 0 && selectedIndex < tabCount {
                tabBarController.selectedIndex += 1
            } else {
                currentlyInteractive = false
            }
        case .changed:
            let fraction = abs(dX / tabBarController.view.bounds.width)
            update(fraction)
        case .cancelled:
            cancel()
            currentlyInteractive = false
        case .ended:
            let fraction = abs(dX / tabBarController.view.bounds.width)
            if fraction >= 0.5 {
                finish()
            } else {
                cancel()
            }
            currentlyInteractive = false
        default:
            break
        }
    }
}
