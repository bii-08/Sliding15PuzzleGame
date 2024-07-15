//
//  GameProgress.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/18.
//

import Foundation

struct GameProgress: Codable {
    var tiles: [Int]
    var picture: Picture?
    var totalMoves: Int
    var timeElapsed: Double
}

enum Picture: String, Identifiable, Codable, CaseIterable {
    var id: Self {
        return self
    }
    case forest, houseAndMoon, sunflower, kidWithFlowers, aussieanimals, sloth, boyAndCat, eating, fly, japaneseHouse, maxAndJess, pancake, temple, udonYa
    var isJustAdded: Bool {
        switch self {
        case .forest, .houseAndMoon, .sunflower, .kidWithFlowers:
            return true
        default:
            return false
        }
    }
}
