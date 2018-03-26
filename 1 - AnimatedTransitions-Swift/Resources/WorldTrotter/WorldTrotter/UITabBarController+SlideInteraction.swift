//
//  UITabBarController+Interaction.swift
//  WorldTrotter
//
//  Created by Nicholas Ollis on 3/26/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

extension UITabBarController {
    func addInteraction(_ slideInteraction: SlideInteraction) {
        let rightEdgeGR = UIScreenEdgePanGestureRecognizer(target: slideInteraction, action: #selector(SlideInteraction.handlePan(_:)))
        
        rightEdgeGR.edges = .right
        rightEdgeGR.delegate = slideInteraction
        view.addGestureRecognizer(rightEdgeGR)
        
        let leftEdgeGR = UIScreenEdgePanGestureRecognizer(target: slideInteraction, action: #selector(SlideInteraction.handlePan(_:)))
        
        leftEdgeGR.edges = .left
        leftEdgeGR.delegate = slideInteraction
        view.addGestureRecognizer(leftEdgeGR)
    }
}
