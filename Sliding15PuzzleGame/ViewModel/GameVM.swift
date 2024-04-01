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
    @Published var selectedPicture: Picture?
    @Published var cancellable: AnyCancellable? = nil
    private var message = ""
    
    @Published var showingDismissAlert = false
    @Published var showingCongratulationAlert = false

    @Published var isPaused = false
    var isShuffling = false
    
    @Published var tiles: [Int] = Array(1...15) + [0]
    
    @Published var totalMoves = 0
    @Published var bestPlay: [Int]
    @Published var timeElapsed: Double = 0.0

    
    private var lastEmptyIndex = -1 // Update the index of the previously empty tile.
    var timer: Timer!
    
    init(size: Int = 4, tileSize: CGFloat = 80, tiles: [Int] = Array(1...15) + [0], totalMoves: Int = 0, bestPlay: [Int] = [1_000_000], timeElapsed: Double = 0.0) {
        self.tiles = tiles
        self.totalMoves = totalMoves
        self.bestPlay = bestPlay
        self.timeElapsed = timeElapsed
        self.size = size
        self.tileSize = tileSize

        // Check if there are any saved data in User Defaults.
        if UserDefaults.standard.data(forKey: "savedProgress") != nil {
            getSavedProgress()
            start()
            if timeElapsed != 0.0 && totalMoves != 0 && tiles != [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                UserDefaults.standard.removeObject(forKey: "savedProgress")
            }
        }
    }
    
    init(size: Int = 4, tileSize: CGFloat = 80, tiles: [Int] = Array(1...15) + [0], totalMoves: Int = 0, bestPlay: [Int] = [1_000_000], timeElapsed: Double = 0.0, picture: Picture?) {
        self.tiles = tiles
        self.totalMoves = totalMoves
        self.bestPlay = bestPlay
        self.timeElapsed = timeElapsed
        self.size = size
        self.tileSize = tileSize
        self.selectedPicture = picture

        // Check if there are any saved data in User Defaults.
        if UserDefaults.standard.data(forKey: "savedProgress") != nil {
            getSavedProgress()
            start()
            if timeElapsed != 0.0 && totalMoves != 0 && tiles != [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                UserDefaults.standard.removeObject(forKey: "savedProgress")
            }
        }
    }
    // FUNCTION: to reset data to initial value in order to redraw GameView.
    func reset() {
        self.timeElapsed = 0.0
        self.totalMoves = 0
        self.isPaused = false
        self.showingDismissAlert = false
        self.tiles = Array(1...15) + [0]
    }
    
    // FUNCTION: to save user's game progress.
    func saveProgress() {
        let data = GameProgress(tiles: tiles, picture: selectedPicture, totalMoves: totalMoves, bestPlay: bestPlay, timeElapsed: timeElapsed)
        if let encodedProgress = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedProgress, forKey: "savedProgress")
        }
    }
    
    // FUNCTION: to get user's game progress.
    private func getSavedProgress() {
        guard
            let data = UserDefaults.standard.data(forKey: "savedProgress"),
            let savedProgress = try? JSONDecoder().decode(GameProgress.self, from: data)
        else { return }
        self.tiles = savedProgress.tiles
        self.totalMoves = savedProgress.totalMoves
        self.bestPlay = savedProgress.bestPlay
        self.timeElapsed = savedProgress.timeElapsed
        self.selectedPicture = savedProgress.picture
    }
    
    // FUNCTION: to move tiles around
    func tapTile(at position: (row: Int, column: Int)) {
        guard !isShuffling else { return }
        guard !showingDismissAlert else { return }
        let index = position.row * size + position.column
        
        // Check if the tapped tile can be moved.
        if canMoveTile(at: position) {
            // Swap the tapped tile with the empty tile.
            if let emptyIndex = tiles.firstIndex(of: 0) {
                tiles.swapAt(index, emptyIndex)
                self.totalMoves += 1
                // Check if totalMoves == 1 or not to start timer.
                if totalMoves == 1 {
                    start()
                }
            }
            // Check whether the user's answer is correct or not.
            if tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                pause()
                bestPlay.append(totalMoves)
                print(bestPlay)
                showingCongratulationAlert.toggle()
                message = "Execellent! It took you \(totalMoves) moves"
                print("Execellent! It took you \(totalMoves) moves")
            }
        }
    }
    
    // FUNCTION: to verify if the selected tile can be moved or not.
    private func canMoveTile(at position: (row: Int, column: Int)) -> Bool {
        //Check if the tapped tile is adjacent to the empty tile.
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
        let _ = Int(counter * 1000) % 1000 // milliseconds
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
        self.isShuffling = true
        lastEmptyIndex = -1
        var num = 5  // The puzzle will be shuffled 50 times.
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            num -= 1
            if num == 3 {
                timer.invalidate() // with the first 10 moves, it will shuffle the tiles with TimeInterval = 0.3 then stop Timer one time when num = 40.
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in // the remaining moves will be shuffled with new timer = 0.05_ faster.
                    num -= 1
                    self.movePiece()
                    if num == 0 {
                        timer.invalidate()
                        self.isShuffling = false
                    }
                }
            }
            self.movePiece()
        }
        timer.fire()
        pause()
        self.timeElapsed = 0.0
        self.totalMoves = 0
    }
    
    // FUNCTION: to swap an empty tile with an adjacent tile.
    private func movePiece() {
        guard let emptyIndex = tiles.firstIndex(of: 0) else { return }
        let emptyPosition = (emptyIndex / size, emptyIndex % size)
        var tilesAroundIndexArray = findTilesAround(at: emptyPosition)
        if let index = tilesAroundIndexArray.firstIndex(of: lastEmptyIndex) {
            tilesAroundIndexArray.remove(at: index)
        }
        // Check if there are valid tiles to swap with.
        guard let randomTileIndex = tilesAroundIndexArray.randomElement() else { return }
        // Swap the empty tile with the randomly selected tile.
        tiles.swapAt(emptyIndex, randomTileIndex)
        lastEmptyIndex = emptyIndex
    }
    
    // FUNCTION: To find the positions of all tiles surrounding the empty tile.
    private func findTilesAround(at position: (row: Int, column: Int)) -> [Int] {
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
    
    // FUNCTION: to disable pause button when needed.
    func isButtonDisable() -> Bool {
        if totalMoves == 0 || showingCongratulationAlert || tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
            return true
        }
        return false
    }
}
