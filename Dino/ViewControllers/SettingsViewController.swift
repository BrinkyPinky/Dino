//
//  SettingsViewController.swift
//  Dino
//
//  Created by Егор Шилов on 04.10.2022.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var musicButton: UIButton!
    
    //states
    private var musicState = DataManager.shared.fetchMusicState() ?? true {
        didSet {
            changeMusicImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeMusicImage()
        
        doneButton.setImage(UIImage(named: "DoneButtonNormal")?.withRenderingMode(.alwaysOriginal), for: .normal)
        doneButton.setImage(UIImage(named: "DoneButtonPressed")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        doneButton.imageView?.image?.withRenderingMode(.alwaysOriginal)
    }
    
    func changeMusicImage() {
        let musicImage = UIImage(named: musicState ? "mark" : "xmark")?.withRenderingMode(.alwaysOriginal)
        
        musicButton.setImage(musicImage, for: .normal)
    }
    
    @IBAction func musicButtonAction(_ sender: Any) {
        musicState.toggle()
        DataManager.shared.saveMusicState(state: musicState)
    }
    
    @IBAction func action(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
