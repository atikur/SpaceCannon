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
        static let None: UInt32             = 0
        static let Halo: UInt32             = 0b1
        static let Ball: UInt32             = 0b10
        static let Edge: UInt32             = 0b100
        static let Shield: UInt32           = 0b1000
        static let LifeBar: UInt32          = 0b10000
        static let ShieldPowerUp: UInt32    = 0b100000
        static let MultiShotPowerUp: UInt32 = 0b1000000
    }
    
    var mainLayer: SKNode!
    var cannon: SKSpriteNode!
    var didShoot = false
    var scoreLabel: SKLabelNode!
    var pointsLabel: SKLabelNode!
    
    let ballSpeed: CGFloat = 1000.0
    let haloLowAngle: CGFloat = 200.0 * CGFloat(M_PI/180)
    let haloHighAngle: CGFloat = 340.0 * CGFloat(M_PI/180)
    let haloSpeed: CGFloat = 100.0
    var shieldPool: [SKSpriteNode]!
    
    var isGameOver: Bool = false
    var menu: Menu!
    
    var numberOfHaloDestroyed: Int!
    var isMultiShotMode = false
    
    let bounceSound = SKAction.playSoundFileNamed("Bounce.caf", waitForCompletion: false)
    let deepExplosionSound = SKAction.playSoundFileNamed("DeepExplosion.caf", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("Explosion.caf", waitForCompletion: false)
    let laserSound = SKAction.playSoundFileNamed("Laser.caf", waitForCompletion: false)
    let zapSound = SKAction.playSoundFileNamed("Zap.caf", waitForCompletion: false)
    
    var ammo: Int! {
        didSet {
            if ammo >= 0 && ammo <= 5 {
                ammoDisplay.texture = SKTexture(imageNamed: "Ammo\(ammo)")
            }
        }
    }
    var ammoDisplay: SKSpriteNode!
    
    var score: Int! {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var pointsValue: Int! {
        didSet {
            pointsLabel.text = "Points: x\(pointsValue)"
        }
    }
    
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
            toPoint: CGPointMake(0, size.height + 100))
        leftEdge.physicsBody?.categoryBitMask = PhysicsCategory.Edge
        
        leftEdge.position = CGPointZero
        self.addChild(leftEdge)
        
        let rightEdge = SKNode()
        rightEdge.physicsBody = SKPhysicsBody(
            edgeFromPoint: CGPointZero,
            toPoint: CGPointMake(0, size.height + 100))
        rightEdge.physicsBody?.categoryBitMask = PhysicsCategory.Edge
        rightEdge.position = CGPointMake(size.width, 0)
        self.addChild(rightEdge)
        
        // add main layer
        mainLayer = SKNode()
        self.addChild(mainLayer)
        
        // add cannon
        cannon = SKSpriteNode(imageNamed: "Cannon")
        cannon.position = CGPointMake(size.width/2, 0)
        self.addChild(cannon)
        
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
        self.runAction(SKAction.repeatActionForever(spawnHaloSequence), withKey: "SpawnHalo")
        
        // spawn shield power up
        let spawnShieldPowerUpAction = SKAction.sequence([
            SKAction.waitForDuration(15, withRange: 2),
            SKAction.runBlock(spawnShieldPowerUp)
            ])
        self.runAction(SKAction.repeatActionForever(spawnShieldPowerUpAction))
        
        // setup ammo
        ammoDisplay = SKSpriteNode(imageNamed: "Ammo5")
        ammoDisplay.anchorPoint = CGPointMake(0.5, 0)
        ammoDisplay.position = cannon.position
        self.addChild(ammoDisplay)
        
        // setup score label
        scoreLabel = SKLabelNode(fontNamed: "Din Alternate")
        scoreLabel.position = CGPointMake(15, 10)
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.fontSize = 15
        self.addChild(scoreLabel)
        
        // setup points label
        pointsLabel = SKLabelNode(fontNamed: "Din Alternate")
        pointsLabel.position = CGPointMake(15, 30)
        pointsLabel.horizontalAlignmentMode = .Left
        pointsLabel.fontSize = 15
        self.addChild(pointsLabel)
    
        // setup menu
        menu = Menu()
        menu.position = CGPointMake(self.size.width/2, self.size.height - 220)
        self.addChild(menu)
        
        // initial values
        ammo = 5
        score = 0
        pointsValue = 1
        scoreLabel.hidden = true
        pointsLabel.hidden = true
        numberOfHaloDestroyed = 0
        isMultiShotMode = false
        
        // increment ammo
        let incrementAmmoAction = SKAction.sequence([
            SKAction.waitForDuration(1),
            SKAction.runBlock {
                if self.ammo < 5 {
                    self.ammo = self.ammo + 1
                }
            }
            ])
        
        self.runAction(SKAction.repeatActionForever(incrementAmmoAction), withKey: "incrementAmmoAction")
        
        // setup shield pool
        shieldPool = []
        
        for i in 0...5 {
            let shield = SKSpriteNode(imageNamed: "Block")
            shield.name = "shield"
            shield.position = CGPointMake(CGFloat(35 + (50 * i)), 90)
            shield.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(32, 9))
            shield.physicsBody?.categoryBitMask = PhysicsCategory.Shield
            shield.physicsBody?.collisionBitMask = PhysicsCategory.None
            shieldPool.append(shield)
        }
        
        isGameOver = true
    }
    
    func shoot() {
        if ammo <= 0 {
            return
        }
        
        let direction = radiansToVector(cannon.zRotation)
        
        shootAtDirection(direction)
        
        ammo = ammo - 1
        
        self.runAction(laserSound)
    }
    
    func multiShoot() {
        ammo = ammo - 1
        
        //let direction = radiansToVector(cannon.zRotation)
        let angles: [CGFloat] = [-0.2, 0.0, 0.2]
        
        for i in 0...2 {
            let direction = angles[i] + cannon.zRotation
            shootAtDirection(radiansToVector(direction))
        }
        
        if ammo <= 0 {
            if let incrementAmmoAction = self.actionForKey("incrementAmmoAction") {
                incrementAmmoAction.speed = 1.0
            }
            cannon.texture = SKTexture(imageNamed: "Cannon")
            
            isMultiShotMode = false
            ammo = 5
        }
    }
    
    func shootAtDirection(direction: CGVector) {
        let ball = Ball(imageNamed: "Ball")
        
        ball.name = "ball"
        ball.position = CGPointMake(
            cannon.position.x + cannon.size.width/2 * direction.dx,
            cannon.position.y + cannon.size.width/2 * direction.dy)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.ShieldPowerUp | PhysicsCategory.MultiShotPowerUp
        ball.physicsBody?.velocity = CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed)
        
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.friction = 0.0
        
        mainLayer.addChild(ball)
        
        // add trail node
        let path = NSBundle.mainBundle().pathForResource("BallTrail", ofType: "sks")!
        let ballTrail = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode!
        ballTrail.targetNode = mainLayer
        ballTrail.position = ball.position
        mainLayer.addChild(ballTrail)
        ball.trail = ballTrail
    }
    
    func spawnHalo() {
        // increase spawn speed
        if let spawnHaloAction = self.actionForKey("SpawnHalo") {
            if spawnHaloAction.speed < 1.5 {
                spawnHaloAction.speed = spawnHaloAction.speed + 0.01
            }
        }
        
        // create Halo node
        let halo = SKSpriteNode(imageNamed: "Halo")
        halo.name = "halo"
        halo.position = CGPointMake(
            CGFloat.random(min: halo.size.width/2, max: self.size.width/2 - halo.size.width/2),
            self.size.height + halo.size.height/2)
        
        halo.physicsBody = SKPhysicsBody(circleOfRadius: halo.size.width/2)
        halo.physicsBody?.categoryBitMask = PhysicsCategory.Halo
        halo.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        halo.physicsBody?.contactTestBitMask = PhysicsCategory.Ball | PhysicsCategory.Shield | PhysicsCategory.LifeBar | PhysicsCategory.Edge
        
        let direction = radiansToVector(CGFloat.random(min: haloLowAngle, max: haloHighAngle))
        
        halo.physicsBody?.velocity = CGVectorMake(
            direction.dx * haloSpeed,
            direction.dx * haloSpeed)
        
        halo.physicsBody?.restitution = 1.0
        halo.physicsBody?.linearDamping = 0.0
        halo.physicsBody?.friction = 0.0
        
        // random point multiplier
        if !isGameOver && arc4random_uniform(6) == 0 {
            halo.texture = SKTexture(imageNamed: "HaloX")
            halo.userData = NSMutableDictionary(object: true as Bool, forKey: "Multiplier")
        }
        
        mainLayer.addChild(halo)
    }
    
    func spawnMultiShotPowerUp() {
        let multiShotPowerUp = SKSpriteNode(imageNamed: "MultiShotPowerUp")
        multiShotPowerUp.name = "multiShotPowerUp"
        multiShotPowerUp.position = CGPointMake(-multiShotPowerUp.size.width, CGFloat.random(min: 150, max: self.size.height - 150))
        multiShotPowerUp.physicsBody = SKPhysicsBody(circleOfRadius: multiShotPowerUp.size.width/2)
        multiShotPowerUp.physicsBody?.categoryBitMask = PhysicsCategory.MultiShotPowerUp
        multiShotPowerUp.physicsBody?.velocity = CGVectorMake(100, CGFloat.random(min: -40, max: 40))
        multiShotPowerUp.physicsBody?.angularVelocity = CGFloat(M_PI)
        multiShotPowerUp.physicsBody?.collisionBitMask = PhysicsCategory.None
        multiShotPowerUp.physicsBody?.angularDamping = 0.0
        multiShotPowerUp.physicsBody?.linearDamping = 0.0
        mainLayer.addChild(multiShotPowerUp)
    }
    
    func spawnShieldPowerUp() {
        let shieldPowerUp = SKSpriteNode(imageNamed: "Block")
        shieldPowerUp.name = "shieldPowerUp"
        shieldPowerUp.position = CGPointMake(self.size.width + shieldPowerUp.size.width, CGFloat.random(min: 150, max: self.size.height - 100))
        shieldPowerUp.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(32, 9))
        shieldPowerUp.physicsBody?.categoryBitMask = PhysicsCategory.ShieldPowerUp
        shieldPowerUp.physicsBody?.velocity = CGVectorMake(-100, CGFloat.random(min: -40, max: 40))
        shieldPowerUp.physicsBody?.angularVelocity = CGFloat(M_PI)
        shieldPowerUp.physicsBody?.linearDamping = 0.0
        shieldPowerUp.physicsBody?.angularDamping = 0.0
        shieldPowerUp.physicsBody?.collisionBitMask = PhysicsCategory.None
        mainLayer.addChild(shieldPowerUp)
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
            score = score + pointsValue
            
            // increase pointsValue if hit a Multiplier Halo
            if let isMultiplier = (firstBody.node?.userData?.valueForKey("Multiplier") as? Bool) {
                pointsValue = pointsValue + 1
            }
            
            if let node = firstBody.node {
                addExplosion(node.position)
            }
            self.runAction(explosionSound)
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            
            numberOfHaloDestroyed = numberOfHaloDestroyed + 1
            
            if numberOfHaloDestroyed == 15 {
                numberOfHaloDestroyed = 0
                self.runAction(SKAction.runBlock(spawnMultiShotPowerUp))
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Halo && secondBody.categoryBitMask == PhysicsCategory.Shield {
            // collision between halo & shield
            if let node = firstBody.node {
                addExplosion(node.position)
            }
            self.runAction(explosionSound)
            
            // restrict halo collision with single shield
            firstBody.categoryBitMask = PhysicsCategory.None
            
            // add shield to pool
            shieldPool.append(secondBody.node as SKSpriteNode)
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Halo && secondBody.categoryBitMask == PhysicsCategory.LifeBar {
            // collision between halo & life bar
            self.runAction(deepExplosionSound)
            
            secondBody.node?.removeFromParent()
            gameOver()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Halo && secondBody.categoryBitMask == PhysicsCategory.Edge {
            // collision between halo & edge
            self.runAction(zapSound)
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Edge {
            // collision between ball & edge
            
            // after three bounce with edge, remove ball
            if let node = firstBody.node as? Ball {
                if node.isKindOfClass(Ball) {
                    node.bounceCount++
                    
                    if node.bounceCount > 3 {
                        node.removeFromParent()
                        pointsValue = 1
                    }
                }
            }
            
            self.runAction(bounceSound)
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.ShieldPowerUp {
            // collision between ball & shield power up
            if !shieldPool.isEmpty {
                let randomIndex = Int(arc4random_uniform(UInt32(shieldPool.count)))
                let shield = shieldPool.removeAtIndex(randomIndex)
                mainLayer.addChild(shield)
            }
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.MultiShotPowerUp {
            // collision between ball & multi-shot power up
            if let node = firstBody.node {
                addExplosion(node.position)
                self.runAction(explosionSound)
                
                isMultiShotMode = true
                
                let incrementAmmoAction = self.actionForKey("incrementAmmoAction")
                incrementAmmoAction?.speed = 0
                ammo = 5
                
                cannon.texture = SKTexture(imageNamed: "GreenCannon")
            }
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
    }
    
    func newGame() {
        ammo = 5
        score = 0
        pointsValue = 1
        numberOfHaloDestroyed = 0
        isMultiShotMode = false
        
        let spawnHaloAction = self.actionForKey("SpawnHalo")
        spawnHaloAction?.speed = 1.0
        
        mainLayer.removeAllChildren()
        
        // add shields
        while !shieldPool.isEmpty {
            let shield = shieldPool.removeAtIndex(0)
            mainLayer.addChild(shield)
        }
        
        // setup life bar
        let lifeBar = SKSpriteNode(imageNamed: "BlueBar")
        lifeBar.position = CGPointMake(self.size.width/2, 70)
        lifeBar.physicsBody = SKPhysicsBody(
            edgeFromPoint: CGPointMake(-lifeBar.size.width/2, 0),
            toPoint: CGPointMake(lifeBar.size.width/2, 0))
        lifeBar.physicsBody?.categoryBitMask = PhysicsCategory.LifeBar
        mainLayer.addChild(lifeBar)
        
        isGameOver = false
        menu.hide()
        scoreLabel.hidden = false
        pointsLabel.hidden = false
    }
    
    func gameOver() {
        mainLayer.enumerateChildNodesWithName("halo", usingBlock: {
            node, _ in
            self.addExplosion(node.position)
            node.removeFromParent()
        })
        
        mainLayer.enumerateChildNodesWithName("ball", usingBlock: {
            node, _ in
            node.removeFromParent()
        })
        
        mainLayer.enumerateChildNodesWithName("shield", usingBlock: {
            node, _ in
            self.shieldPool.append(node as SKSpriteNode)
            node.removeFromParent()
        })
        
        mainLayer.enumerateChildNodesWithName("shieldPowerUp", usingBlock: {
            node, _ in
            node.removeFromParent()
        })
        
        mainLayer.enumerateChildNodesWithName("multiShotPowerUp", usingBlock: {
            node, _ in
            node.removeFromParent()
        })
        
        menu.score = self.score
        if self.score > menu.topScore {
            menu.topScore = self.score
        }
        
        isGameOver = true
        scoreLabel.hidden = true
        pointsLabel.hidden = true
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock {
                self.menu.show()
            }
            ]))
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
            if !isGameOver {
                didShoot = true
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if isGameOver && menu.touchable {
                let point = (touch as UITouch).locationInNode(menu)
                let node: SKNode = menu.nodeAtPoint(point)
                
                if node.name == "PlayButton" {
                    newGame()
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        if didShoot {
            if isMultiShotMode {
                self.multiShoot()
            } else {
                self.shoot()
            }
            didShoot = false
        }
        
        // clean up balls that are out of frame
        mainLayer.enumerateChildNodesWithName("ball", usingBlock: {
            node, _ in
            if let ball = node as? Ball {
                ball.updateTrail()
            }
            
            if !CGRectContainsPoint(self.frame, node.position) {
                node.removeFromParent()
                if !self.isMultiShotMode {
                    self.pointsValue = 1
                }
            }
        })
        
        // remove halo if they move to bottom of the screen
        mainLayer.enumerateChildNodesWithName("halo", usingBlock: {
            node, _ in
            if node.position.y + node.frame.size.height < 0  {
                node.removeFromParent();
            }
        })
        
        // remove shield power ups
        mainLayer.enumerateChildNodesWithName("shieldPowerUp", usingBlock: {
            node, _ in
            if node.position.x + node.frame.size.width < 0 {
                node.removeFromParent();
            }
        })
        
        // remove multi-shot power ups
        mainLayer.enumerateChildNodesWithName("multiShotPowerUp", usingBlock: {
            node, _ in
            if node.position.x > self.frame.size.width + node.frame.size.width {
                node.removeFromParent()
            }
        })
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
