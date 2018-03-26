//
//  TabDelegate.swift
//  WorldTrotter
//
//  Created by Nicholas Ollis on 3/26/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

class TabDelegate: NSObject, UITabBarControllerDelegate {
    private let slideTransition = SlideTransition()
    var layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let fromIndex = tabBarController.viewControllers!.index(of: fromVC)!
        let toIndex = tabBarController.viewControllers!.index(of: toVC)!
        
        if (layoutDirection == .leftToRight) {
            slideTransition.animationDirection = (fromIndex < toIndex) ? .left : .right
        } else {
            slideTransition.animationDirection = (fromIndex < toIndex) ? .right : .left
        }

        return slideTransition
    }
}
