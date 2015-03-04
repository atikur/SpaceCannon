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
    
    var title: SKSpriteNode!
    var scoreBoard: SKSpriteNode!
    var playButton: SKSpriteNode!
    
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
        self.touchable = false
        
        // animate title
        title.position = CGPointMake(0, 280)
        title.alpha = 0.0
        
        let fadeInAction = SKAction.fadeInWithDuration(0.5)
        
        let animateTitleAction = SKAction.group([
            SKAction.moveToY(140, duration: 0.5),
            fadeInAction
            ])
        animateTitleAction.timingMode = .EaseOut
        title.runAction(animateTitleAction)
        
        // animate score board
        scoreBoard.xScale = 4.0
        scoreBoard.yScale = 4.0
        scoreBoard.alpha = 0.0
        
        let animateScoreBoardAction = SKAction.group([
            SKAction.scaleTo(1.0, duration: 0.5),
            fadeInAction
            ])
        animateTitleAction.timingMode = .EaseOut
        scoreBoard.runAction(animateScoreBoardAction)
        
        // animate play button
        playButton.alpha = 0.0
        
        let animatePlayButtonAction = SKAction.fadeInWithDuration(2.0)
        animatePlayButtonAction.timingMode = .EaseIn
        playButton.runAction(animatePlayButtonAction, completion: {
            self.touchable = true
        })
    }
    
    func hide() {
        self.touchable = false
        
        let animateMenuAction = SKAction.scaleTo(0.0, duration: 0.5)
        animateMenuAction.timingMode = .EaseIn
        
        self.runAction(animateMenuAction, completion: {
            self.hidden = true
            self.xScale = 1.0
            self.yScale = 1.0
        })
    }
    
    override init() {
        super.init()
        
        title = SKSpriteNode(imageNamed: "Title")
        title.position = CGPointMake(0, 140)
        self.addChild(title)
        
        scoreBoard = SKSpriteNode(imageNamed: "ScoreBoard")
        scoreBoard.position = CGPointMake(0, 70)
        self.addChild(scoreBoard)
        
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        playButton.name = "PlayButton"
        playButton.position = CGPointMake(0, 0)
        self.addChild(playButton)
        
        scoreLabel = SKLabelNode(fontNamed: "Din Alternate")
        scoreLabel.fontSize = 30
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(-52, -20)
        scoreBoard.addChild(scoreLabel)
        
        topScoreLabel = SKLabelNode(fontNamed: "Din Alternate")
        topScoreLabel.fontSize = 30
        topScoreLabel.text = "\(topScore)"
        topScoreLabel.position = CGPointMake(48, -20)
        scoreBoard.addChild(topScoreLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
