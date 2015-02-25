//
//  GameScene.swift
//  Space Cannon
//
//  Created by Atikur Rahman on 2/16/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None: UInt32 = 0
        static let Halo: UInt32 = 0b1
        static let Ball: UInt32 = 0b10
        static let Edge: UInt32 = 0b100
    }
    
    var mainLayer: SKNode!
    var cannon: SKSpriteNode!
    var didShoot = false
    
    let ballSpeed: CGFloat = 1000.0
    let haloLowAngle: CGFloat = 200.0 * CGFloat(M_PI/180)
    let haloHighAngle: CGFloat = 340.0 * CGFloat(M_PI/180)
    let haloSpeed: CGFloat = 100.0
    
    var ammo: Int! {
        didSet {
            if ammo >= 0 && ammo <= 5 {
                ammoDisplay.texture = SKTexture(imageNamed: "Ammo\(ammo)")
            }
        }
    }
    var ammoDisplay: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        // turn off gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "StarField")
        background.position = CGPointMake(size.width/2, size.height/2)
        background.blendMode = SKBlendMode.Replace
        self.addChild(background)
        
        // add edges
        let leftEdge = SKNode()
        leftEdge.physicsBody = SKPhysicsBody(
            edgeFromPoint: CGPointZero,
            toPoint: CGPointMake(0, size.height))
        leftEdge.physicsBody?.categoryBitMask = PhysicsCategory.Edge
        
        leftEdge.position = CGPointZero
        self.addChild(leftEdge)
        
        let rightEdge = SKNode()
        rightEdge.physicsBody = SKPhysicsBody(
            edgeFromPoint: CGPointZero,
            toPoint: CGPointMake(0, size.height))
        rightEdge.physicsBody?.categoryBitMask = PhysicsCategory.Edge
        rightEdge.position = CGPointMake(size.width, 0)
        self.addChild(rightEdge)
        
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
        
        // spawn halo
        let spawnHaloAction = SKAction.runBlock {
            self.spawnHalo()
        }
        
        let waitAction = SKAction.waitForDuration(2, withRange: 1)
        
        let spawnHaloSequence = SKAction.sequence([spawnHaloAction, waitAction])
        self.runAction(SKAction.repeatActionForever(spawnHaloSequence))
        
        // setup ammo
        ammoDisplay = SKSpriteNode(imageNamed: "Ammo5")
        ammoDisplay.anchorPoint = CGPointMake(0.5, 0)
        ammoDisplay.position = cannon.position
        mainLayer.addChild(ammoDisplay)
        ammo = 5
        
        // increment ammo
        let incrementAmmoAction = SKAction.sequence([
            SKAction.waitForDuration(1),
            SKAction.runBlock {
                if self.ammo < 5 {
                    self.ammo = self.ammo + 1
                }
            }
            ])
        
        self.runAction(SKAction.repeatActionForever(incrementAmmoAction))
    }
    
    func shoot() {
        if ammo <= 0 {
            return
        }
        
        let ball = SKSpriteNode(imageNamed: "Ball")
        let direction = radiansToVector(cannon.zRotation)
        
        ball.name = "ball"
        ball.position = CGPointMake(
            cannon.position.x + cannon.size.width/2 * direction.dx,
            cannon.position.y + cannon.size.width/2 * direction.dy)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        ball.physicsBody?.velocity = CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed)
        
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.friction = 0.0
        
        mainLayer.addChild(ball)
        
        ammo = ammo - 1
    }
    
    func spawnHalo() {
        // create Halo node
        let halo = SKSpriteNode(imageNamed: "Halo")
        halo.position = CGPointMake(
            CGFloat.random(min: halo.size.width/2, max: self.size.width/2 - halo.size.width/2),
            self.size.height + halo.size.height/2)
        
        halo.physicsBody = SKPhysicsBody(circleOfRadius: halo.size.width/2)
        halo.physicsBody?.categoryBitMask = PhysicsCategory.Halo
        halo.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        halo.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        let direction = radiansToVector(CGFloat.random(min: haloLowAngle, max: haloHighAngle))
        
        halo.physicsBody?.velocity = CGVectorMake(
            direction.dx * haloSpeed,
            direction.dx * haloSpeed)
        
        halo.physicsBody?.restitution = 1.0
        halo.physicsBody?.linearDamping = 0.0
        halo.physicsBody?.friction = 0.0
        
        mainLayer.addChild(halo)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody!
        var secondBody: SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Halo && secondBody.categoryBitMask == PhysicsCategory.Ball {
            // collision between halo & ball
            addExplosion(firstBody.node!.position)
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
    }
    
    func addExplosion(point: CGPoint) {
        let path = NSBundle.mainBundle().pathForResource("HaloExplosion", ofType: "sks")
        
        let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as SKEmitterNode
        
        explosion.position = point
        self.addChild(explosion)
        
        let waitAction = SKAction.waitForDuration(1.5)
        let removeAction = SKAction.removeFromParent()
        explosion.runAction(SKAction.sequence([waitAction, removeAction]))
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
