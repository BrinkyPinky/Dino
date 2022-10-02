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
}
