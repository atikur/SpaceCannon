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
    var didShoot = false
    
    let ballSpeed: CGFloat = 1000
    
    override func didMoveToView(view: SKView) {
        // turn off gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
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
    
    func shoot() {
        let ball = SKSpriteNode(imageNamed: "Ball")
        let direction = radiansToVector(cannon.zRotation)
        
        ball.name = "ball"
        ball.position = CGPointMake(
            cannon.position.x + cannon.size.width/2 * direction.dx,
            cannon.position.y + cannon.size.width/2 * direction.dy)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.velocity = CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed)
        mainLayer.addChild(ball)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            didShoot = true
        }
    }
    
    override func didSimulatePhysics() {
        if didShoot {
            self.shoot()
            didShoot = false
        }
        
        // clean up balls that are out of frame
        mainLayer.enumerateChildNodesWithName("ball", usingBlock: {
            node, _ in
            if !CGRectContainsPoint(self.frame, node.position) {
                node.removeFromParent()
            }
        })
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
