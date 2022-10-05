//
//  GameScene.swift
//  Dino
//
//  Created by Егор Шилов on 29.09.2022.
//

import SpriteKit
import GameplayKit
import RxSwift
import RxCocoa

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // view model
    var viewModel: GameSceneViewModelProtocol!
    
    // game status
    var isGamePaused = true
    var isDinoBended = false
    
    // nodes
    var dinoNode: SKSpriteNode!
    var slimeNode: SKSpriteNode!
    var playButtonNode: SKSpriteNode!
    var optionsButtonNode: SKSpriteNode!
    
    //obstacles
    var obstacleEagleNode: SKSpriteNode!
    var obstacleStoneNode: SKSpriteNode!
    var obstacleSlimeNode: SKSpriteNode!

    //music
    var music: SKAudioNode!

    // score
    var scoreLabel = SKLabelNode(text: "0")
    var referenceTime: Double = 0
    var score: Int = 0 {
        didSet  {
            guard score != oldValue, score != 0 else { return }
            guard score % 100 == 0 else { return }
            guard viewModel.movementSpeed < 6 else { return }
            viewModel.movementSpeed += 0.2
            DispatchQueue.global(qos: .background).async {
                for _ in 1...4 {
                    self.scoreLabel.alpha = 0
                    Thread.sleep(forTimeInterval: 0.4)
                    self.scoreLabel.alpha = 1
                    Thread.sleep(forTimeInterval: 0.4)
                }
            }
        }
    }
    
    // obstacles array
    lazy var obstacles = [obstacleSlimeNode, obstacleStoneNode, obstacleEagleNode]
    
    // texture actions
    var slimeIdleAnimation: SKAction!
    var dinoRunningAnimation: SKAction!
    var bendedDinoAnimation: SKAction!
    var slimeDyingAnimation: SKAction!
    var eagleAnimation: SKAction!
    
    //last obstacle that was used
    var lastMovementObstacle: SKSpriteNode!
    
    //settings
    var settingsViewController: UIViewController!
    
    func createAnimation(imagesCount: Int, imageBaseName: String, frameRate: Double) -> SKAction {
        var textures: [SKTexture] = []
        for i in 1...imagesCount {
            let texture = SKTexture(imageNamed: "\(imageBaseName)\(i)")
            texture.filteringMode = .nearest
            textures.append(texture)
        }
        return SKAction.animate(with: textures, timePerFrame: frameRate)
    }
    
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
    
    override func didMove(to view: SKView) {
        viewModel = GameSceneViewModel()
        
        settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
        
        loadTextures()
        
        self.addChild(self.scoreLabel)
        
        music = childNode(withName: "music") as? SKAudioNode
        let sound = SKAction.playSoundFileNamed("Music500.mp3", waitForCompletion: false)
        music.run(sound)
        music.autoplayLooped = true
        
        obstacleStoneNode = childNode(withName: "obstacleStone") as? SKSpriteNode
        dinoNode = childNode(withName: "dino") as? SKSpriteNode
        obstacleSlimeNode = childNode(withName: "obstacleSlime") as? SKSpriteNode
        slimeNode = obstacleSlimeNode.childNode(withName: "slime") as? SKSpriteNode
        playButtonNode = childNode(withName: "playButton") as? SKSpriteNode
        optionsButtonNode = childNode(withName: "optionsButton") as? SKSpriteNode
        obstacleEagleNode = childNode(withName: "obstacleEagle") as? SKSpriteNode
        
        obstacleSlimeNode.physicsBody?.restitution = 2
        
        obstacleEagleNode.run(SKAction.repeatForever(eagleAnimation))
        
        slimeNode.run(SKAction.repeatForever(slimeIdleAnimation))
        
        dinoNode.texture?.filteringMode = .nearest
        dinoNode.physicsBody?.mass = 100
        dinoNode.physicsBody?.restitution = -1
        
        dinoNode.run(SKAction.repeatForever(dinoRunningAnimation))
        
        playButtonNode.physicsBody?.mass = 30
        optionsButtonNode.physicsBody?.mass = 30
        
        scoreLabel.fontName = "Toriko"
        scoreLabel.position.y = 100
        
        playButtonNode.texture?.filteringMode = .nearest
        optionsButtonNode.texture?.filteringMode = .nearest
        
        self.physicsWorld.contactDelegate = self
        
        showMainMenu()
        
        createEnvironment()
    }
        
    override func update(_ currentTime: TimeInterval) {
        moveEnvironment()
        self.dinoNode.position.x = -(self.scene?.frame.width)!/3
        guard !isGamePaused else {
            lastMovementObstacle?.position.x = self.scene!.frame.width/1.5
            return
        }
        scoreCounter(currentTime: currentTime)
        moveObstacles()
    }
    
    private func scoreCounter(currentTime: Double) {
        if referenceTime == 0 {
            referenceTime = currentTime
        } else {
            score = lround((currentTime-referenceTime)*5)
            scoreLabel.text = "\(score)"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self) else { return }
        
        if touchLocation.x <= 0 {
            print("Touched left side")
            dinoNode.removeAllActions()
            dinoNode.run(SKAction.repeatForever(bendedDinoAnimation))
            isDinoBended = true
        } else {
            if dinoNode.position.y < -95 {
                print("Touched right side")
                dinoNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50000))
            }
        }
        
        guard self.scene!.contains(playButtonNode) else { return }
        if playButtonNode.contains(touchLocation) {
            startGame()
        } else if optionsButtonNode.contains(touchLocation) {
            let rootVC = self.view?.window?.rootViewController
            rootVC?.present(settingsViewController, animated: true)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDinoBended else { return }
        isDinoBended = false
        dinoNode.removeAllActions()
        dinoNode.run(SKAction.repeatForever(dinoRunningAnimation))
    }
    
    // MARK: Start Game
    
    private func startGame() {
            
            self.scene?.removeChildren(in: [self.optionsButtonNode, self.playButtonNode])
            self.isGamePaused = false
        
    }
    
    // MARK: Contact logic
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.contactTestBitMask == 2 && contact.bodyB.contactTestBitMask == 1 {
            slimeNode.run(slimeDyingAnimation)
        }
        
        guard contact.bodyA.contactTestBitMask == contact.bodyB.contactTestBitMask else { return }
        if contact.bodyA.node!.name == "obstacleEagle" || contact.bodyB.node!.name == "obstacleEagle" {
            if isDinoBended {
                return
            } else {
                showMainMenu()
                return
            }
        }
        
        showMainMenu()
    }
    
    // MARK: show Main Menu
    
    private func showMainMenu() {
        isGamePaused = true
        
        DataManager.shared.saveScore(value: score)
        scoreLabel.text = "Best score: \(DataManager.shared.fetchScore() ?? 0)"
        
        referenceTime = 0
        
        playButtonNode.position = CGPoint(x: 0, y: self.scene!.frame.height)
        optionsButtonNode.position = CGPoint(x: 0, y: self.scene!.frame.height/2+50)
        
        if !self.children.contains(playButtonNode) && !self.children.contains(optionsButtonNode) {
            self.addChild(playButtonNode)
            self.addChild(optionsButtonNode)
        }
        
        viewModel.movementSpeed = 3
    }
    
    // MARK: Move Obstacles
        
    func moveObstacles() {
        if lastMovementObstacle == nil {
            lastMovementObstacle = obstacles.randomElement()!!
        } else if lastMovementObstacle.position.x <= -(scene?.frame.width)!/1.5 {
            lastMovementObstacle.position.x = scene!.frame.width/1.5
            lastMovementObstacle = obstacles.randomElement()!!
        }
        
        guard lastMovementObstacle.name != "obstacleEagle" else {
            lastMovementObstacle.position.x -= viewModel.movementSpeed + 3
            return
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
