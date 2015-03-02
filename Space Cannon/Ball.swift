//
//  Ball.swift
//  Space Cannon
//
//  Created by Atikur Rahman on 3/2/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
   
    var trail: SKEmitterNode?
    var bounceCount: Int = 0
    
    func updateTrail() {
        if let trail = trail {
            trail.position = self.position
        }
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        
        if let trail = trail {
            trail.particleBirthRate = 0
            
            let removeTrailAction = SKAction.sequence([
                SKAction.waitForDuration(NSTimeInterval(trail.particleLifetime + trail.particleLifetimeRange)),
                SKAction.removeFromParent()
                ])
            
            self.runAction(removeTrailAction)
        }
    }
    
}
