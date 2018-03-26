//
//  TabDelegate.swift
//  WorldTrotter
//
//  Created by Michael Ward on 5/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class TabDelegate: NSObject, UITabBarControllerDelegate {
    
    private let slideTransition = SlideTransition()

    func tabBarController(_ tabBarController: UITabBarController,
                          animationControllerForTransitionFrom fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let fromIndex = tabBarController.viewControllers!.index(of: fromVC)!
        let toIndex = tabBarController.viewControllers!.index(of: toVC)!
        
        slideTransition.animationDirection = (fromIndex < toIndex) ? .left : .right
        return slideTransition
    }
    
}
