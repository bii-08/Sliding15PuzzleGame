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
    var bestPlay: [Int]
    var timeElapsed: Double
}

enum Picture: String, Identifiable, Codable {
    var id: Self {
        return self
    }
    case boyAndCat, eating, fly, japaneseHouse, maxAndJess, pancake, temple, udonYa
}
