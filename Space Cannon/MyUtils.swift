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