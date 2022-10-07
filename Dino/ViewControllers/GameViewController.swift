//
//  GameViewController.swift
//  Dino
//
//  Created by Егор Шилов on 29.09.2022.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
