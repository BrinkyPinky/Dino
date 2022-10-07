//
//  SettingsViewController.swift
//  Dino
//
//  Created by Егор Шилов on 04.10.2022.
//

import UIKit
import SpriteKit

class SettingsViewController: UIViewController {
        
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var musicButton: UIButton!
    @IBOutlet var soundEffectsButton: UIButton!
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    //states
    private var musicState = DataManager.shared.fetchMusicState() ?? true {
        didSet {
            changeImage(button: musicButton, state: musicState)
            gameSceneDelegate?.musicSetup(musicState: musicState)
        }
    }
    private var soundEffectsState = DataManager.shared.fetchSoundEffectsState() ?? true {
        didSet {
            changeImage(button: soundEffectsButton, state: soundEffectsState)
            gameSceneDelegate?.soundEffectsSetup(soundEffectsState: soundEffectsState)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeImage(button: musicButton, state: musicState)
        changeImage(button: soundEffectsButton, state: soundEffectsState)

        doneButton.setImage(UIImage(named: "DoneButtonNormal")?.withRenderingMode(.alwaysOriginal), for: .normal)
        doneButton.setImage(UIImage(named: "DoneButtonPressed")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        doneButton.imageView?.image?.withRenderingMode(.alwaysOriginal)
    }
    
    func changeImage(button: UIButton, state: Bool) {
        let musicImage = UIImage(named: state ? "mark" : "xmark")?.withRenderingMode(.alwaysOriginal)
        
        button.setImage(musicImage, for: .normal)
    }
    
    @IBAction func musicButtonAction(_ sender: Any) {
        musicState.toggle()
        DataManager.shared.saveMusicState(state: musicState)
    }
    
    @IBAction func soundEffectsButtonAction(_ sender: Any) {
        soundEffectsState.toggle()
        DataManager.shared.saveSoundEffectsState(state: soundEffectsState)
    }
    
    @IBAction func action(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
