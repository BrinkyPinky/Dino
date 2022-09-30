//
//  GameScene.swift
//  Dino
//
//  Created by Егор Шилов on 29.09.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        createEnvironment()
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveEnvironment()
    }
    
    // MARK: Move Environment
    
    func moveEnvironment() {
        enumerateChildNodes(withName: "BackgroundLayer1") { [unowned self] node, _ in
            moveNode(shift: 1.8, node: node)
        }
        
        enumerateChildNodes(withName: "Ground") { [unowned self] node, _ in
            moveNode(shift: 2, node: node)
        }
        
        enumerateChildNodes(withName: "ForegroundGround") { [unowned self] node, _ in
            moveNode(shift: 2.3, node: node)
        }
    }
}

extension GameScene {
    
    // MARK: Create Environment
    
    func createEnvironment() {
        for i in 0..<2 {
            createBackgroundNode(
                number: i,
                nodeName: "Ground",
                imageName: "ground",
                height: self.scene!.size.width/6.5,
                zPosition: 0,
                yPosition: -(self.scene?.size.height)!/2
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "BackgroundLayer1",
                imageName: "backgroundLayer1",
                height: 315,
                zPosition: -1,
                yPosition: 35
            )
            
            createBackgroundNode(
                number: i,
                nodeName: "ForegroundGround",
                imageName: "foregroundGround",
                height: self.scene!.size.width/7,
                zPosition: 1,
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
