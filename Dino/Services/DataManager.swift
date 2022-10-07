//
//  DataManager.swift
//  Dino
//
//  Created by Егор Шилов on 02.10.2022.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    func saveScore(value: Int) {
        guard value > fetchScore() ?? 0 else { return }
        UserDefaults.standard.set(value, forKey: "bestScore")
    }
    
    func fetchScore() -> Int? {
        UserDefaults.standard.integer(forKey: "bestScore")
    }
    
    func saveMusicState(state: Bool) {
        UserDefaults.standard.set(state, forKey: "musicState")
    }
    
    func fetchMusicState() -> Bool? {
        UserDefaults.standard.bool(forKey: "musicState")
    }
    
    func saveSoundEffectsState(state: Bool) {
        UserDefaults.standard.set(state, forKey: "soundEffectsState")
    }
    
    func fetchSoundEffectsState() -> Bool? {
        UserDefaults.standard.bool(forKey: "soundEffectsState")
    }
}
