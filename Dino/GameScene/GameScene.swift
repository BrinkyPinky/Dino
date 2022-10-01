//
//  GameScene.swift
//  Dino
//
//  Created by Егор Шилов on 29.09.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var viewModel: GameSceneViewModelProtocol!
    var obstacleStone: SKSpriteNode!
    
    var playButton: SKSpriteNode!
    var optionsButton: SKSpriteNode!
    
    var isGamePaused = true
    
    var dinoNode: SKSpriteNode!
    var slimeNode: SKSpriteNode!
    var slimeBounceZone: SKSpriteNode!
    
    var scoreLabel = SKLabelNode(text: "0")
    
    var referenceTime: Double = 0
    
    override func didMove(to view: SKView) {
        viewModel = GameSceneViewModel()
        
        obstacleStone = childNode(withName: "obstacleStone") as? SKSpriteNode
        dinoNode = childNode(withName: "dino") as? SKSpriteNode
        slimeBounceZone = childNode(withName: "slimeBounceZone") as? SKSpriteNode
        slimeNode = slimeBounceZone.childNode(withName: "slime") as? SKSpriteNode
        playButton = childNode(withName: "playButton") as? SKSpriteNode
        optionsButton = childNode(withName: "optionsButton") as? SKSpriteNode
        
        slimeBounceZone.physicsBody?.restitution = 2
        
        var slimeIdleTextures: [SKTexture] = []
        for i in 1...2 {
            let slimeIdleTexture = SKTexture(imageNamed: "slimeidle\(i)")
            slimeIdleTexture.filteringMode = .nearest
            slimeIdleTextures.append(slimeIdleTexture)
        }
        let slimeIdleAnimation = SKAction.animate(with: slimeIdleTextures, timePerFrame: 0.2)
        slimeNode.run(SKAction.repeatForever(slimeIdleAnimation))
        
        dinoNode.texture?.filteringMode = .nearest
        dinoNode.physicsBody?.mass = 100
        dinoNode.physicsBody?.restitution = -1
        var dinoTextures: [SKTexture] = []
        for i in 1...6 {
            let dinoTexture = SKTexture(imageNamed: "dinoRunning\(i)")
            dinoTexture.filteringMode = .nearest
            dinoTextures.append(dinoTexture)
        }
        let dinoAnimation = SKAction.animate(with: dinoTextures, timePerFrame: 0.1)
        dinoNode.run(SKAction.repeatForever(dinoAnimation))
        
        playButton.physicsBody?.mass = 30
        optionsButton.physicsBody?.mass = 30
        
        scoreLabel.fontName = "Toriko"
        scoreLabel.position.y = 100
        
        playButton.texture?.filteringMode = .nearest
        optionsButton.texture?.filteringMode = .nearest
        
        self.physicsWorld.contactDelegate = self
        
        showMainMenu()
        
        createEnvironment()
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveEnvironment()
        guard !isGamePaused else { return }
        scoreCounter(currentTime: currentTime)
        moveObstacles()
    }
    
    private func scoreCounter(currentTime: Double) {
        if referenceTime == 0 {
            referenceTime = currentTime
        } else {
            scoreLabel.text = "\(lround((currentTime-referenceTime)*5))"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dinoNode.position.y < -95 {
            dinoNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50000))
        }

        guard let touch = touches.first?.location(in: self) else { return }
        
        if playButton.contains(touch) {
            startGame()
        } else if optionsButton.contains(touch) {
            print("settings")
        }
    }
    
    // MARK: Start Game
    
    private func startGame() {
        playButton.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50000))
        optionsButton.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50000))
        
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            self.removeChildren(in: [self.playButton, self.optionsButton])
            self.isGamePaused = false
            self.addChild(self.scoreLabel)
        }
    }
    
    // MARK: Game Over
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard contact.bodyA.contactTestBitMask == contact.bodyB.contactTestBitMask else { return }
        showMainMenu()
    }
    
    // MARK: show Main Menu
    
    private func showMainMenu() {
        isGamePaused = true

        referenceTime = 0
        
        playButton.position = CGPoint(x: 0, y: self.scene!.frame.height)
        optionsButton.position = CGPoint(x: 0, y: self.scene!.frame.height/2)
        
        if !self.children.contains(playButton) && !self.children.contains(optionsButton) {
            self.addChild(playButton)
            self.addChild(optionsButton)
            self.removeChildren(in: [self.scoreLabel])
        }
    }
    
    // MARK: Move Obstacles
    
    var lastMovementObstacle: SKSpriteNode!
    
    func moveObstacles() {
        let sequence = [slimeBounceZone, obstacleStone]
        
        if lastMovementObstacle == nil {
            lastMovementObstacle = sequence.randomElement()!!
        }else if lastMovementObstacle.position.x <= -(scene?.frame.width)!/1.5 {
            lastMovementObstacle.position.x = scene!.frame.width/1.5
            lastMovementObstacle = sequence.randomElement()!!
        }
        
        lastMovementObstacle.position.x -= viewModel.movementSpeed
    }
    
    // MARK: Move Environment
    
    func moveEnvironment() {
        viewModel.environments.forEach { environment in
            enumerateChildNodes(withName: environment.name) { [unowned self] node, _ in
                moveNode(shift: environment.shift, node: node)
            }
        }
    }
}

extension GameScene {
    
    // MARK: Create Environment
    
    func createEnvironment() {
        for i in 0..<2 {
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer7",
                imageName: "backgroundLayer7",
                height: self.scene!.size.width/2.3,
                zPosition: -8,
                yPosition: -60
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer6",
                imageName: "backgroundLayer6",
                height: 170,
                zPosition: -7,
                yPosition: -45
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "LightsBackgroundLayer5",
                imageName: "lightsBackgroundLayer5",
                height: self.scene!.size.width/3,
                zPosition: -6,
                yPosition: -(self.scene!.size.height)/100
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer4",
                imageName: "backgroundLayer4",
                height: 170,
                zPosition: -5,
                yPosition: -45
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer3",
                imageName: "backgroundLayer3",
                height: 170,
                zPosition: -4,
                yPosition: -45
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "LightsBackgroundLayer2",
                imageName: "lightsBackgroundLayer2",
                height: self.scene!.size.width/3,
                zPosition: -3,
                yPosition: -(self.scene?.size.height)!/100
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer1",
                imageName: "backgroundLayer1",
                height: 315,
                zPosition: -2,
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
    
    // MARK: Environments creation and moving methods
    
    func moveNode(shift: CGFloat, node: SKNode) {
        node.position.x -= shift
        if node.position.x < -(self.scene?.size.width)! {
            node.position.x += (self.scene?.size.width)! * 2
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
