//
//  GameSceneViewModel.swift
//  Dino
//
//  Created by Егор Шилов on 01.10.2022.
//

import Foundation

protocol GameSceneViewModelProtocol {
    var movementSpeed: CGFloat { get set }
    var environments: [MoveEnvironment] { get }
}

class GameSceneViewModel: GameSceneViewModelProtocol {
    // MARK: BackgroundEnvironment
    var movementSpeed: CGFloat = 3
    
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
}
