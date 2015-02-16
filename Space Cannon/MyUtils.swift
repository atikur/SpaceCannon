//
//  MyUtils.swift
//  Space Cannon
//
//  Created by Atikur Rahman on 2/16/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import Foundation
import SpriteKit

func radiansToVector(radians: CGFloat) -> CGVector {
    return CGVector(dx: cos(radians), dy: sin(radians))
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    static func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}