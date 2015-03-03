//
//  Menu.swift
//  Space Cannon
//
//  Created by Atikur Rahman on 3/1/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class Menu: SKNode {
    var scoreLabel: SKLabelNode!
    var topScoreLabel: SKLabelNode!
    var touchable = true
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var topScore: Int {
        set {
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "topScore")

            topScoreLabel.text = "\(topScore)"
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("topScore")
        }
    }
    
    func show() {
        self.hidden = false
        self.touchable = true
    }
    
    func hide() {
        self.hidden = true
        self.touchable = false
    }
    
    override init() {
        super.init()
        
        let title = SKSpriteNode(imageNamed: "Title")
        title.position = CGPointMake(0, 140)
        self.addChild(title)
        
        let scoreBoard = SKSpriteNode(imageNamed: "ScoreBoard")
        scoreBoard.position = CGPointMake(0, 70)
        self.addChild(scoreBoard)
        
        let playButton = SKSpriteNode(imageNamed: "PlayButton")
        playButton.name = "PlayButton"
        playButton.position = CGPointMake(0, 0)
        self.addChild(playButton)
        
        scoreLabel = SKLabelNode(fontNamed: "Din Alternate")
        scoreLabel.fontSize = 30
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(-52, 50)
        self.addChild(scoreLabel)
        
        topScoreLabel = SKLabelNode(fontNamed: "Din Alternate")
        topScoreLabel.fontSize = 30
        topScoreLabel.text = "\(topScore)"
        topScoreLabel.position = CGPointMake(48, 50)
        self.addChild(topScoreLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
