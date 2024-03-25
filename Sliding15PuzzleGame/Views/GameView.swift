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
    @StateObject private var vm = GameVM()
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("\(vm.formatMmSs(counter: vm.timeElapsed))")
                    .foregroundColor(Color("timerAndMovesButton"))
                    .font(.largeTitle)
                    .bold()
                Spacer()
                ForEach(0..<vm.size) { row in
                    HStack {
                        ForEach(0..<vm.size) { column in
                            TileView(number: vm.tiles[row * vm.size + column], size: vm.tileSize) { ///
                                vm.tapTile(at: (row, column))
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    Button {
                        vm.isPaused.toggle()
                        // Have to pause the timer here
                        vm.pause()
                    } label: {
                        VStack {
                            Image(systemName: "pause.rectangle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(vm.isButtonDisable() ? Color(.gray) : Color("tile"))
                                .bold()
                            
                            Text("Pause")
                                .animation(.none)
                                .foregroundColor(vm.isButtonDisable() ? Color(.gray) : Color("timerAndMovesButton")) ///
                        }
                    }
                    .disabled(vm.isButtonDisable())
                    
                    Spacer()
                    Button(action: {
                        vm.shuffle()
                    }, label: {
                        VStack {
                            Image(systemName: "plus.viewfinder")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(vm.isShowingAlert == true ? Color(.gray) : Color("tile"))
                                .bold()
                            Text("New Game")
                                .foregroundColor(vm.isShowingAlert == true ? Color(.gray) : Color("timerAndMovesButton"))
                        }
                    })
                    .disabled(vm.isShowingAlert == true)
                }
                .padding(40)
                .foregroundColor(Color("timerAndMovesButton"))
                .font(.title3)
                .bold()
                Spacer()
            }
            .overlay(vm.isPaused ? overlayView : nil)
            // This is an alert asking user for a confirmation if they want to continue the previous game or not
            .alert("Confirmation", isPresented: $vm.isShowingConfirmation) {
                Button("Continue") { 
                    vm.isContinued = true
                    vm.start()
                }
                Button("New Game") { 
                    vm.shuffle()
                    UserDefaults.standard.removeObject(forKey: "savedProgress")
                }
            } message: {
                Text("Do you want to continue?")
            }
        }
        .overlay(vm.isShowingAlert ?
                 DialogView(isShowingAlert: $vm.isShowingAlert, title: "Excellent!", message: "It took you \(vm.totalMoves) moves", bestPlay: vm.bestPlay.min() ?? 0, buttonTitle: "New Game", action: vm.shuffle)
           : nil)
        .onDisappear {
            vm.pause()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                vm.pause()
                vm.saveProgress()
            case .inactive:
                if !vm.isPaused {
                    vm.start()
                }
                if vm.isShowingAlert {
                    vm.pause()
                }
                if vm.timeElapsed != 0.0 && vm.tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                    vm.pause()
                }
                if vm.totalMoves == 0 && vm.tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                    vm.pause()
                }
                if vm.timeElapsed == 0.0 && vm.totalMoves == 0 {
                    vm.pause()
                }
            default:
                break
            }
        }
    }

}

extension GameView {
    private var overlayView: some View {
        ZStack {
            Color(.white.opacity(0.6)).ignoresSafeArea()
            
            Button {
                vm.isPaused.toggle()
                // have to resume the timer here
                vm.start()
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
    
    GameView()
}

