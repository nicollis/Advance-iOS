//
//  StaircaseLayer.swift
//  FeelTheBurn
//
//  Created by Michael L. Ward on 12/12/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class StaircaseLayer: CALayer {

    @objc dynamic var stepCount = 11
    @objc dynamic var dottedStepIndex = 0
    
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        needsDisplayOnBoundsChange = true
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        commonInit()
        if let copyFrom = layer as? StaircaseLayer {
            self.stepCount = copyFrom.stepCount
            self.dottedStepIndex = copyFrom.dottedStepIndex
        }
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        switch key {
        case "stepCount", "dottedStepIndex":
            return true
        default:
            return super.needsDisplay(forKey: key)
        }
    }
    
    override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        defer { UIGraphicsPopContext() }
        let stepWidth = bounds.width / CGFloat(stepCount)
        let stepHeight = bounds.height / CGFloat(stepCount)
        let stepPath = UIBezierPath()
        // Start at lower left, building a series of lines that look like stairs.
        var currentPoint = CGPoint(x: 0, y: bounds.maxY - 3)
        stepPath.move(to: currentPoint)
        for _ in 0 ..< stepCount {
            currentPoint.x += stepWidth
            stepPath.addLine(to: currentPoint)
            currentPoint.y -= stepHeight
            stepPath.addLine(to: currentPoint)
        }
        stepPath.lineWidth = 3
        UIColor.black.setStroke()
        stepPath.stroke()
        // Draw dot
        let center = CGPoint(x: stepWidth * (CGFloat(dottedStepIndex) + 0.5),
                             y: stepHeight * (CGFloat(stepCount - dottedStepIndex) - 0.5))
        let dotSize = stepHeight / 4
        let dotPath = UIBezierPath(arcCenter: center,
                                   radius: dotSize,
                                   startAngle: 0, endAngle: 2 * .pi,
                                   clockwise: true)
        dotPath.fill()
    }
    
}
