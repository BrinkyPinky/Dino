//
//  GameSceneViewModel.swift
//  Dino
//
//  Created by Егор Шилов on 01.10.2022.
//

import Foundation

protocol GameSceneViewModelProtocol {
    var isGamePaused: Bool { get set }
    var isDinoBended: Bool { get set }
    var movementSpeed: CGFloat { get set }
    var environments: [MoveEnvironment] { get }
    var score: Int { get }
    var referenceTime: Double { get set }
    init(gameScene: GameScene)
    func scoreCounter(currentTime: Double, action: (Int) -> Void)
}

class GameSceneViewModel: GameSceneViewModelProtocol {
    
    unowned var gameScene: GameScene!
    
    // game status
    var isGamePaused = true
    var isDinoBended = false
    
    // game speed
    var movementSpeed: CGFloat = 3
    
    //background environment
    var environments: [MoveEnvironment] {
        get {
            return [
                MoveEnvironment(name: "BackgroundLayer7", shift: movementSpeed * (9 / 20)),
                MoveEnvironment(name: "BackgroundLayer6", shift: movementSpeed  * (11 / 20)),
                MoveEnvironment(name: "LightsBackgroundLayer5", shift: movementSpeed  * (13 / 20)),
                MoveEnvironment(name: "BackgroundLayer4", shift: movementSpeed  * (7 / 10)),
                MoveEnvironment(name: "BackgroundLayer3", shift: movementSpeed  * (4 / 5)),
                MoveEnvironment(name: "LightsBackgroundLayer2", shift: movementSpeed  * (17 / 20)),
                MoveEnvironment(name: "BackgroundLayer1", shift: movementSpeed  * (9 / 10)),
                MoveEnvironment(name: "Ground", shift: movementSpeed ),
                MoveEnvironment(name: "ForegroundGround", shift: movementSpeed  * (23 / 20))
            ]
        }
    }
    
    //score
    var referenceTime: Double = 0
    var score = 0 {
        didSet {
            guard score != oldValue, score != 0, score % 100 == 0, movementSpeed < 6 else { return }
            movementSpeed += 0.2
            DispatchQueue.global(qos: .background).async {
                for _ in 1...4 {
                    self.gameScene.scoreLabel.alpha = 0
                    Thread.sleep(forTimeInterval: 0.4)
                    self.gameScene.scoreLabel.alpha = 1
                    Thread.sleep(forTimeInterval: 0.4)
                }
            }
        }
    }
    
    required init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    //score logic
    func scoreCounter(currentTime: Double, action: (Int) -> Void) {
        if referenceTime == 0 {
            referenceTime = currentTime
        } else {
            score = lround((currentTime-referenceTime)*5)
            action(score)
        }
    }
}
