//
//  GameView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/11.
//

import SwiftUI
import Combine

struct GameView: View {
    
    @Environment(\.scenePhase) private var scenePhase

    let size: Int
    
    let tileSize: CGFloat
    @State var cancellable: AnyCancellable?
    @State var message = ""
    
    @State var isShowingAlert = false
    @State var isPaused = false
    @State var tiles: [Int] = Array(1...15) + [0]
    
    @State var totalMoves = 0
    @State var bestPlay: [Int]
    @State var timeElapsed: Double = 0.0
    
   
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                Spacer()
                Text("\(formatMmSs(counter: timeElapsed))")
                    .foregroundColor(Color("timerAndMovesButton"))
                    .font(.largeTitle)
                    .bold()
                Spacer()
                ForEach(0..<size) { row in
                    HStack {
                        ForEach(0..<size) { column in
                            TileView(number: tiles[row * size + column], size: tileSize) {
                                self.tapTile(at: (row, column))
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    Button {
                        isPaused.toggle()
                        // Have to pause the timer here
                        pause()
                    } label: {
                        VStack {
                            Image(systemName: "pause.rectangle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(totalMoves == 0 || isShowingAlert == true ? Color(.gray) : Color("tile"))
                                .bold()
                            
                            Text("Pause")
                                .animation(.none)
                                .foregroundColor(totalMoves == 0 || isShowingAlert == true ? Color(.gray) : Color("timerAndMovesButton"))
                            
                        }
                    }
                    .disabled(totalMoves == 0 || isShowingAlert == true)
                    
                    Spacer()
                    Button(action: {
                        shuffle()
                    }, label: {
                        VStack {
                            Image(systemName: "plus.viewfinder")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isShowingAlert == true ? Color(.gray) : Color("tile"))
                                .bold()
                            Text("New Game")
                                .foregroundColor(isShowingAlert == true ? Color(.gray) : Color("timerAndMovesButton"))
                        }
                    })
                    .disabled(isShowingAlert == true)
                }
                .padding(40)
                .foregroundColor(Color("timerAndMovesButton"))
                .font(.title3)
                .bold()
                Spacer()
            }
            .overlay(isPaused ? overlayView : nil)
            
        }
        .overlay(isShowingAlert ? DialogView(isShowingAlert: $isShowingAlert, title: "Excellent!", message: "It took you \(totalMoves) moves", bestPlay: bestPlay.min() ?? 0, buttonTitle: "New Game", action: shuffle) : nil)
        .onDisappear {
            pause()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                pause()
            }
            if phase == .inactive && !isPaused {
                start()
            }
            if phase == .inactive && isShowingAlert {
                pause()
            }
        }
        
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
                timeElapsed += 1.0
            })
    }
    
    // FUNCTION: to pause timer.
    func pause() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    
    
    // FUNCTION: to shuffle tile array with a moving motion.
    func shuffle() {
        var num = 100
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            
            num -= 1
            if num == 0 {
                timer.invalidate()
            }
            movePiece()
        }
        timer.fire()
        pause()
        self.timeElapsed = 0.0
        self.totalMoves = 0
        //        let randomMoves = Int.random(in: 25...100)
        //        var moves = 0
        //        repeat {
        //            movePiece()
        //            moves += 1
        //        } while moves < randomMoves
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
}

extension GameView {
    private var overlayView: some View {
        ZStack {
            Color(.white.opacity(0.6)).ignoresSafeArea()
            
            Button {
                isPaused.toggle()
                // have to resume the timer here
                start()
            } label: {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("timerAndMovesButton"))
            }
            
        }
    }
}



#Preview {
    
    GameView(size: 4, tileSize: 80, bestPlay: [10_000_000])
}

