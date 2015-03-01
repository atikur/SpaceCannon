//
//  Menu.swift
//  Space Cannon
//
//  Created by Atikur Rahman on 3/1/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class Menu: SKNode {
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
