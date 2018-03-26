//
//  FireView.swift
//  FeelTheBurn
//
//  Created by Michael L. Ward on 12/12/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class FireView: UIView {

    override class var layerClass: AnyClass {
        return CAEmitterLayer.self
    }
    
    var emitterLayer: CAEmitterLayer {
        return layer as! CAEmitterLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.height)
        emitterLayer.emitterSize = CGSize(width: 300, height: 0)
        emitterLayer.emitterShape = kCAEmitterLayerLine
        emitterLayer.backgroundColor = UIColor.clear.cgColor
    }
    
    func startBurn() {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "flameParticle")?.cgImage
        cell.birthRate = 100
        cell.lifetime = 1.5
        cell.lifetimeRange = 0.8
        cell.velocity = 100
        cell.velocityRange = 20
        cell.emissionRange = .pi / 6
        cell.emissionLongitude = 0
        cell.redRange = 0
        cell.redSpeed = 0
        cell.greenRange = 0.3
        cell.blueRange = 0.3
        cell.alphaSpeed = -0.5
        cell.scaleSpeed = -0.5
        cell.spin = .pi / 2
        cell.color = UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 0.5).cgColor
        cell.scale = 1.0
        cell.scaleRange = 0.25
        cell.name = "fire"
        emitterLayer.emitterCells = [ cell ]
        
        let fireMove = UIInterpolatingMotionEffect(keyPath: "layer.emitterCells.fire.velocity",
                                                   type: .tiltAlongVerticalAxis)
        fireMove.minimumRelativeValue = 1
        fireMove.maximumRelativeValue = 200
        addMotionEffect(fireMove)
    }
    
    func stopBurn() {
        emitterLayer.emitterCells = nil
    }

}
