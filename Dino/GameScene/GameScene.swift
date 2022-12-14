//
//  GameScene.swift
//  Dino
//
//  Created by Егор Шилов on 29.09.2022.
//

import SpriteKit
import GameplayKit
import MediaPlayer

protocol GameSceneDelegate: AnyObject {
    func musicSetup(musicState: Bool)
    func soundEffectsSetup(soundEffectsState: Bool)
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneDelegate {
    
    // view model
    var viewModel: GameSceneViewModelProtocol!
    
    // nodes
    var dinoNode: SKSpriteNode!
    var slimeNode: SKSpriteNode!
    var playButtonNode: SKSpriteNode!
    var optionsButtonNode: SKSpriteNode!
    
    //obstacles
    var obstacleEagleNode: SKSpriteNode!
    var obstacleStoneNode: SKSpriteNode!
    var obstacleSlimeNode: SKSpriteNode!
    lazy var obstacles = [obstacleSlimeNode, obstacleStoneNode, obstacleEagleNode]
    
    //music
    var music: AVAudioPlayer?
    var soundEffects: SKAudioNode?
    var dinoRunningSoundEffect: AVAudioPlayer?
    let slimeDyingSoundEffect = SKAction.playSoundFileNamed("slimeDying.mp3", waitForCompletion: true)
    let jumpSound = SKAction.playSoundFileNamed("JumpSound.wav", waitForCompletion: true)
    let bendSound = SKAction.playSoundFileNamed("bendSound.wav", waitForCompletion: true)
    
    // score
    var scoreLabel = SKLabelNode(text: "0")
    
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
    
    override func didMove(to view: SKView) {
        viewModel = GameSceneViewModel(gameScene: self)
        loadTextures()
        setup()
        showMainMenu()
        createEnvironment()
        musicSetup(musicState: DataManager.shared.fetchMusicState() ?? true)
        soundEffectsSetup(soundEffectsState: DataManager.shared.fetchSoundEffectsState() ?? true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveEnvironment()
        self.dinoNode.position.x = -(self.scene?.frame.width)!/3
        guard !viewModel.isGamePaused else {
            lastMovementObstacle?.position.x = self.scene!.frame.width/1.5
            return
        }
        viewModel.scoreCounter(currentTime: currentTime) { score in
            scoreLabel.text = "\(score)"
        }
        moveObstacles()
    }
    
    // MARK: UserInteraction (Touches)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self) else { return }
        guard self.scene!.contains(playButtonNode) else {
            if touchLocation.x <= 0 { // touched left side
                dinoNode.removeAllActions()
                dinoNode.run(SKAction.repeatForever(bendedDinoAnimation))
                soundEffects?.run(bendSound)
                viewModel.isDinoBended = true
            } else { // touched right side
                if dinoNode.position.y < -95 {
                    soundEffects?.run(jumpSound)
                    dinoNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50000))
                }
            }
            return
        }
        
        if playButtonNode.contains(touchLocation) {
            startGame()
        } else if optionsButtonNode.contains(touchLocation) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let settingsViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController else { return }
            let rootVC = self.view?.window?.rootViewController
            rootVC?.present(settingsViewController, animated: true)
            settingsViewController.gameSceneDelegate = self
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard viewModel.isDinoBended else { return }
        viewModel.isDinoBended = false
        dinoNode.removeAllActions()
        dinoNode.run(SKAction.repeatForever(dinoRunningAnimation))
    }
    
    // MARK: Start Game
    
    private func startGame() {
        self.scene?.removeChildren(in: [self.optionsButtonNode, self.playButtonNode])
        self.viewModel.isGamePaused = false
    }
    
    // MARK: Contact logic
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.contactTestBitMask == 2 && contact.bodyB.contactTestBitMask == 1 {
            slimeNode.run(slimeDyingAnimation)
            soundEffects?.run(slimeDyingSoundEffect)
        }
        
        if contact.bodyA.node!.name == "physicalGround" || contact.bodyB.node!.name == "physicalGround" {
            if contact.bodyA.node!.name == "dino" || contact.bodyB.node!.name == "dino" {
                DispatchQueue.global(qos: .background).async {
                    self.dinoRunningSoundEffect?.volume = 0.1
                }
            }
        }
        
        guard contact.bodyA.contactTestBitMask == contact.bodyB.contactTestBitMask else { return }
        if contact.bodyA.node!.name == "obstacleEagle" || contact.bodyB.node!.name == "obstacleEagle" {
            if viewModel.isDinoBended {
                return
            } else {
                showMainMenu()
                return
            }
        }
        
        showMainMenu()
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA.node!.name == "physicalGround" || contact.bodyB.node!.name == "physicalGround" {
            if contact.bodyA.node!.name == "dino" || contact.bodyB.node!.name == "dino" {
                self.dinoRunningSoundEffect?.volume = 0
            }
        }
    }
    
    // MARK: show Main Menu
    
    private func showMainMenu() {
        viewModel.isGamePaused = true
        
        DataManager.shared.saveScore(value: viewModel.score)
        scoreLabel.text = "Best score: \(DataManager.shared.fetchScore() ?? 0)"
        
        viewModel.referenceTime = 0
        
        playButtonNode.position = CGPoint(x: 0, y: self.scene!.frame.height)
        optionsButtonNode.position = CGPoint(x: 0, y: self.scene!.frame.height/2+50)
        
        if !self.children.contains(playButtonNode) && !self.children.contains(optionsButtonNode) {
            self.addChild(playButtonNode)
            self.addChild(optionsButtonNode)
        }
        
        viewModel.movementSpeed = 3
    }
    
    // MARK: Move Obstacles
    
    private func moveObstacles() {
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
    
    private func moveEnvironment() {
        viewModel.environments.forEach { environment in
            enumerateChildNodes(withName: environment.name) { [unowned self] node, _ in
                node.position.x -= environment.shift
                if node.position.x < -(self.scene?.size.width)! {
                    node.position.x += (self.scene?.size.width)! * 2
                }
            }
        }
    }
}

