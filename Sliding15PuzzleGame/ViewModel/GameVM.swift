//
//  GameVM.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/15.
//

import Foundation
import Combine
import CoreData
import UIKit

class GameVM: ObservableObject {
    let size: Int
    let tileSize: CGFloat
    

    @Published var cancellable: AnyCancellable? = nil
    @Published var message = ""
    
    @Published var isShowingAlert = false 
    @Published var isShowingConfirmation = false
    @Published var isContinued = false
    
    @Published var isPaused = false
    @Published var tiles: [Int] = Array(1...15) + [0]
    
    @Published var totalMoves = 0
    @Published var bestPlay: [Int]
    @Published var timeElapsed: Double = 0.0
    
    init(size: Int = 4, tileSize: CGFloat = 80, tiles: [Int] = Array(1...15) + [0], totalMoves: Int = 0, bestPlay: [Int] = [1_000_000], timeElapsed: Double = 0.0) {
        self.tiles = tiles
        self.totalMoves = totalMoves
        self.bestPlay = bestPlay
        self.timeElapsed = timeElapsed
        self.size = size
        self.tileSize = tileSize
        
        print("initializing game")
        
        if UserDefaults.standard.data(forKey: "savedProgress") != nil {
            isShowingConfirmation = true
            getSavedProgress()
        }
    }

     // FUNCTION: to save user's game progress
    func saveProgress() {
        let data = GameProgress(tiles: tiles, totalMoves: totalMoves, bestPlay: bestPlay, timeElapsed: timeElapsed)
        if let encodedProgress = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedProgress, forKey: "savedProgress")
        }
        
    }
    
    // FUNCTION: to get user's game progress
    func getSavedProgress() {
        guard
            let data = UserDefaults.standard.data(forKey: "savedProgress"),
            let savedProgress = try? JSONDecoder().decode(GameProgress.self, from: data)
        else { return }
        self.tiles = savedProgress.tiles
        self.totalMoves = savedProgress.totalMoves
        self.bestPlay = savedProgress.bestPlay
        self.timeElapsed = savedProgress.timeElapsed
    }
    


    
    // FUNCTION: to move tiles around
    func tapTile(at position: (row: Int, column: Int)) {
        let index = position.row * size + position.column
        
        // Check if the tapped tile can be moved
        if canMoveTile(at: position) {
            // Swap the tapped tile with the empty tile
            if let emptyIndex = tiles.firstIndex(of: 0) {
                tiles.swapAt(index, emptyIndex)
                self.totalMoves += 1
                // Check if totalMoves == 1 or not to start timer
                if totalMoves == 1 {
                    start()
                }
            }
            // Check if user's answer is right or not
            if tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                pause()
                bestPlay.append(totalMoves)
                print(bestPlay)
                isShowingAlert.toggle()
                message = "Execellent! It took you \(totalMoves) moves"
                print("Execellent! It took you \(totalMoves) moves")
            }
            
        }
        
    }
    
    // FUNCTION: to verify if the selected tile can be moved or not.
    func canMoveTile(at position: (row: Int, column: Int)) -> Bool {
        //Check if the tapped tilw is adjacent to the empty tile
        let emptyIndex = tiles.firstIndex(of: 0)!
        let emptyPosition = (emptyIndex / size, emptyIndex % size)
        if tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
            return false
        }
        return abs(emptyPosition.0 - position.row) + abs(emptyPosition.1 - position.column) == 1
    }
    
    // FUNCTION: to convert time to a string in order to display.
    func formatMmSs(counter: Double) -> String {
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60
        let milliseconds = Int(counter * 1000) % 1000
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // FUNCTION: to start timer.
    func start() {
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                self.timeElapsed += 1.0
            })
    }
    
    // FUNCTION: to pause timer.
    func pause() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    // FUNCTION: to shuffle tile array with a moving motion.
    func shuffle() {
        var num = 20
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            num -= 1
            if num == 0 {
                timer.invalidate()
            }
            self.movePiece()
        }
        timer.fire()
        pause()
        self.timeElapsed = 0.0
        self.totalMoves = 0
    }
    
    // FUNCTION: to swap an empty tile with an adjacent tile.
    func movePiece() {
        
        let emptyIndex = tiles.firstIndex(of: 0)!
        let emptyPosition = (emptyIndex / size, emptyIndex % size)
        let tilesAroundIndexArray = findTilesAround(at: emptyPosition)
        if let randomTileIndex = tilesAroundIndexArray.randomElement() {
            tiles.swapAt(emptyIndex, randomTileIndex)
        }
    }
    
    // FUNCTION: To find the positions of all tiles surrounding the empty tile.
    func findTilesAround(at position: (row: Int, column: Int)) -> [Int] {
        var tilesAroundIndexArray: [Int] = []
        
        let tile1 = (position.row, position.column + 1)
        let tile2 = (position.row, position.column - 1)
        let tile3 = (position.row + 1, position.column)
        let tile4 = (position.row - 1, position.column)
        
        if tile1.1 < size {
            tilesAroundIndexArray.append(tile1.0 * size + tile1.1)
        }
        if tile2.1 >= 0 {
            tilesAroundIndexArray.append(tile2.0 * size + tile2.1)
        }
        if tile3.0 < size {
            tilesAroundIndexArray.append(tile3.0 * size + tile3.1)
        }
        if tile4.0 >= 0 {
            tilesAroundIndexArray.append(tile4.0 * size + tile4.1)
        }
        
        return tilesAroundIndexArray
    }
    
    // FUNCTION: to disable pause button when needed
    func isButtonDisable() -> Bool {
        if totalMoves == 0 || isShowingAlert || tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
            return true
        }
        return false
    }
}
