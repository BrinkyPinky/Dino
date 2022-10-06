//
//  GameScene + Setup.swift
//  Dino
//
//  Created by Егор Шилов on 06.10.2022.
//

import Foundation
import SpriteKit
import AVFAudio

extension GameScene {
    
    // MARK: Generally setup
    
    func setup() {
        settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
        
        self.addChild(self.scoreLabel)
        scoreLabel.fontName = "Toriko"
        scoreLabel.position.y = 100
        
        obstacleStoneNode = childNode(withName: "obstacleStone") as? SKSpriteNode
        
        let url = URL(fileReferenceLiteralResourceName: "Music500.mp3")
        music = try! AVAudioPlayer(contentsOf: url)
        music.numberOfLoops = 999
        music.play()
        
        dinoNode = childNode(withName: "dino") as? SKSpriteNode
        dinoNode.physicsBody?.mass = 100
        dinoNode.physicsBody?.restitution = 0
        dinoNode.run(SKAction.repeatForever(dinoRunningAnimation))
        
        obstacleSlimeNode = childNode(withName: "obstacleSlime") as? SKSpriteNode
        obstacleSlimeNode.physicsBody?.restitution = 2
        
        slimeNode = obstacleSlimeNode.childNode(withName: "slime") as? SKSpriteNode
        slimeNode.run(SKAction.repeatForever(slimeIdleAnimation))
        
        playButtonNode = childNode(withName: "playButton") as? SKSpriteNode
        playButtonNode.physicsBody?.mass = 30
        
        optionsButtonNode = childNode(withName: "optionsButton") as? SKSpriteNode
        optionsButtonNode.physicsBody?.mass = 30
        
        obstacleEagleNode = childNode(withName: "obstacleEagle") as? SKSpriteNode
        obstacleEagleNode.run(SKAction.repeatForever(eagleAnimation))
        
        playButtonNode.texture?.filteringMode = .nearest
        optionsButtonNode.texture?.filteringMode = .nearest
        
        self.physicsWorld.contactDelegate = self
    }
    
    // MARK: Animations
    
    func loadTextures() {
        slimeIdleAnimation = createAnimation(
            imagesCount: 2,
            imageBaseName: "slimeidle",
            frameRate: 0.2
        )
        dinoRunningAnimation = createAnimation(
            imagesCount: 6,
            imageBaseName: "dinoRunning",
            frameRate: 0.1
        )
        bendedDinoAnimation = createAnimation(
            imagesCount: 6,
            imageBaseName: "bendedDino",
            frameRate: 0.1
        )
        slimeDyingAnimation = createAnimation(
            imagesCount: 13,
            imageBaseName: "slimeDying",
            frameRate: 0.05
        )
        eagleAnimation = createAnimation(
            imagesCount: 6,
            imageBaseName: "eagle",
            frameRate: 0.1
        )
    }
    
    func createAnimation(imagesCount: Int, imageBaseName: String, frameRate: Double) -> SKAction {
        var textures: [SKTexture] = []
        for i in 1...imagesCount {
            let texture = SKTexture(imageNamed: "\(imageBaseName)\(i)")
            texture.filteringMode = .nearest
            textures.append(texture)
        }
        return SKAction.animate(with: textures, timePerFrame: frameRate)
    }
    
    // MARK: Create environment
    
    func createEnvironment() {
        for i in 0..<2 {
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer7",
                imageName: "backgroundLayer7",
                height: self.scene!.size.width/2.3,
                zPosition: -9,
                yPosition: -60
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer6",
                imageName: "backgroundLayer6",
                height: 170,
                zPosition: -8,
                yPosition: -45
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "LightsBackgroundLayer5",
                imageName: "lightsBackgroundLayer5",
                height: self.scene!.size.width/3,
                zPosition: -7,
                yPosition: -(self.scene!.size.height)/100
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer4",
                imageName: "backgroundLayer4",
                height: 170,
                zPosition: -6,
                yPosition: -45
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer3",
                imageName: "backgroundLayer3",
                height: 170,
                zPosition: -5,
                yPosition: -45
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "LightsBackgroundLayer2",
                imageName: "lightsBackgroundLayer2",
                height: self.scene!.size.width/3,
                zPosition: -4,
                yPosition: -(self.scene?.size.height)!/100
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer1",
                imageName: "backgroundLayer1",
                height: 315,
                zPosition: -3,
                yPosition: 35
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "Ground",
                imageName: "ground",
                height: self.scene!.size.width/6.5,
                zPosition: -1,
                yPosition: -(self.scene?.size.height)!/2
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "ForegroundGround",
                imageName: "foregroundGround",
                height: self.scene!.size.width/7,
                zPosition: 0,
                yPosition: -(self.scene?.size.height)!/2
            )
        }
    }
    
    func createBackgroundNode(number: Int, nodeName: String, imageName: String, height: Double, zPosition: CGFloat, yPosition: CGFloat) {
        let backgroundNode = SKSpriteNode(imageNamed: imageName)
        backgroundNode.name = nodeName
        backgroundNode.size = CGSize(width: (self.scene?.size.width)!, height: height)
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundNode.position = CGPoint(
            x: CGFloat(number) * backgroundNode.size.width,
            y: yPosition
        )
        backgroundNode.zPosition = zPosition
        self.addChild(backgroundNode)
    }
}
