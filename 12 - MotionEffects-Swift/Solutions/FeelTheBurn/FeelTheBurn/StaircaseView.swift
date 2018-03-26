//
//  StaircaseView.swift
//  FeelTheBurn
//
//  Created by Michael L. Ward on 12/12/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class StaircaseView: UIView {

    override class var layerClass: AnyClass {
        return StaircaseLayer.self
    }
    
    var staircaseLayer: StaircaseLayer {
        return layer as! StaircaseLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        staircaseLayer.backgroundColor = UIColor.clear.cgColor
    }

}
