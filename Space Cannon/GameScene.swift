//
//  GameScene.swift
//  Space Cannon
//
//  Created by Atikur Rahman on 2/16/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var mainLayer: SKNode!
    var cannon: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "StarField")
        background.position = CGPointMake(size.width/2, size.height/2)
        background.blendMode = SKBlendMode.Replace
        self.addChild(background)
        
        // add main layer
        mainLayer = SKNode()
        self.addChild(mainLayer)
        
        // add cannon
        cannon = SKSpriteNode(imageNamed: "Cannon")
        cannon.position = CGPointMake(size.width/2, 0)
        mainLayer.addChild(cannon)
        
        // rotate cannon
        let halfRotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration: 2)
        let rotateAction = SKAction.sequence([halfRotateAction, halfRotateAction.reversedAction()])
        cannon.runAction(SKAction.repeatActionForever(rotateAction))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
