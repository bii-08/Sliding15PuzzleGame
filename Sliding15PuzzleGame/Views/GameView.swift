//
//  GameView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/11.
//

import SwiftUI
import Combine
import UIKit

struct GameView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: GameVM
  
    init(vm: GameVM) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            VStack {
                controlPanel
                    .padding(.horizontal)
                Spacer()
                Spacer()
            }
            VStack {
                Spacer()
                Spacer()
                Spacer()
                // Logics to display picture
                if let picture = vm.selectedPicture {
                    HStack {
                        // Game Picture
                        Image("\(picture.rawValue)")
                            .resizable()
                            .frame(width: vm.userDeviceHeight <= 812 && vm.userDeviceWidth <= 375 || vm.userDeviceHeight <= 667 && vm.userDeviceWidth <= 375 ? 160 : 200, height: vm.userDeviceHeight <= 812 && vm.userDeviceWidth <= 375 || vm.userDeviceHeight <= 667 && vm.userDeviceWidth <= 375 ? 160 : 200)
                            .cornerRadius(5)
                        
                           // Hint/ Hide button
                            Button {
                                vm.showingHint.toggle()
                            } label: {
                                VStack {
                                    Image(systemName: vm.showingHint ? "eye.slash" : "lightbulb.min.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(vm.showingDismissAlert || vm.isShuffling || vm.showingCongratulationAlert ? Color.gray : Color("tile"))
                                       
                                    Text(vm.showingHint ? "Hide" : "Hint")
                                        .animation(.none)
                                        .font(Font.custom("Chalkboard SE", size: 18))
                                        .frame(minWidth: 65)
                                        .foregroundColor(vm.showingDismissAlert || vm.isShuffling || vm.showingCongratulationAlert ? Color.gray : Color("timerAndMovesButton"))
                                }
                            }
                            .disabled(vm.showingDismissAlert || vm.isShuffling || vm.showingCongratulationAlert)
                    }
                    
                }
                Spacer()
                ForEach(0..<vm.size, id: \.self) { row in
                    HStack {
                        ForEach(0..<vm.size, id: \.self) { column in
                            TileView(number: vm.tiles[row * vm.size + column], size: vm.userDeviceHeight <= 812 && vm.userDeviceWidth <= 375 || vm.userDeviceHeight <= 667 && vm.userDeviceWidth <= 375 ? 70 : vm.tileSize, picture: vm.selectedPicture, showingHint: vm.showingHint) {
                                vm.tapTile(at: (row, column))
                            }
                        }
                    }
                }
                
                Spacer()
                Spacer()
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            
            // This is an alert asking the user for confirmation on whether they want to DISMISS the game or not.
            if vm.showingDismissAlert {
                CustomAlertView(title: "Confirmation", message: "Are you sure you want to cancel the game?", primaryButtonTitle: "Yes", action1: {
                    UserDefaults.standard.removeObject(forKey: "savedProgress")
                    vm.reset()
                    dismiss()
                }, secondaryButtonTitle: "No") {
                    vm.start()
                    withAnimation {
                        vm.showingDismissAlert = false
                    }
                }
                .zIndex(5)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(vm.isPaused ? overlayView : nil)
        .overlay(vm.showingCongratulationAlert ?
                 DialogView(isShowingAlert: $vm.showingCongratulationAlert, title: "Excellent!", message: "It took you \(vm.totalMoves) moves", bestPlay: bestPlay(), buttonTitle: "New Game", action: vm.shuffle)
            .padding(30)
                 : nil)
        .onDisappear {
            vm.pause()
            vm.showingHint = false
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                vm.pause()
                // CASE: Saving game when app went to background, tiles are being moved && tiles' set up value is not initial value [1,...,15,0]
                if vm.totalMoves != 0 && vm.tiles != [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                    vm.saveProgress()
                }
            case .inactive:
                // CASE: When the game is not paused, then the start() function will be active.
                if !vm.isPaused {
                    vm.start()
                }
                // CASE: When the game is finished or showingDismissAlert is popped up.
                if vm.showingCongratulationAlert || vm.showingDismissAlert {
                    vm.pause()
                }
                // CASE: When user has moved some tiles and finished it correctly -> stop counting time.
                if vm.timeElapsed != 0.0 && vm.tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                    vm.pause()
                }
                // CASE: When tiles are not moved and tiles's set up value is initial value.
                if vm.totalMoves == 0 && vm.tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                    vm.pause()
                }
                // CASE: When tiles are not moved and total moves = 0
                if vm.timeElapsed == 0.0 && vm.totalMoves == 0 {
                    vm.pause()
                }
            default:
                break
            }
        }
        
    }
    
    private func bestPlay() -> Int {
        if vm.selectedPicture != nil {
            return UserDefaults.standard.integer(forKey: "pictureScore")
        } else {
            return UserDefaults.standard.integer(forKey: "classicScore")
        }
    }
    
}

extension GameView {
    private var overlayView: some View {
        ZStack {
            Color(.white.opacity(0.6)).ignoresSafeArea()
            Button {
                vm.isPaused.toggle()
                // Have to resume the timer here.
                vm.start()
            } label: {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("timerAndMovesButton"))
            }
        }
    }
    
    private var controlPanel: some View {
        HStack(spacing: vm.userDeviceHeight <= 812 && vm.userDeviceWidth <= 375 || vm.userDeviceHeight <= 667 && vm.userDeviceWidth <= 375 ? 5 : 20) {
            Spacer()
            // Back button
            Button(action: {
                if vm.timeElapsed == 0.0 && vm.tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] {
                    dismiss()
                } else if vm.timeElapsed != 0.0 && vm.tiles == [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0] && !vm.showingCongratulationAlert {
                    dismiss()
                    vm.reset()
                } else {
                    withAnimation {
                        vm.showingDismissAlert = true
                    }
                    vm.pause()
                }
            }) {
                Image(systemName: "arrowshape.turn.up.backward.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
            .tint(Color("tile"))
            .disabled(vm.showingDismissAlert || vm.isShuffling || vm.showingCongratulationAlert)
            
            // Pause buttom
            Button {
                vm.isPaused.toggle()
                // Have to pause the timer here.
                vm.pause()
            } label: {
                VStack(spacing: 4.5) {
                    Image(systemName: "pause.rectangle")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(vm.isButtonDisable() || vm.showingDismissAlert ? Color(.gray) : Color("tile"))
                        .bold()
                    
                    Text("Pause")
                        .animation(.none)
                        .font(Font.custom("Chalkboard SE", size: 18))
                        .frame(minWidth: 65)
                        .foregroundColor(vm.isButtonDisable() || vm.showingDismissAlert ? Color(.gray) : Color("timerAndMovesButton"))
                }
            }
            .disabled(vm.isButtonDisable() || vm.showingDismissAlert)
            
            // Shuffle button
            Button(action: {
                vm.shuffle()
            }, label: {
                VStack(spacing: 4.5) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .frame(width: 25, height: 20)
                        .foregroundColor(vm.showingCongratulationAlert == true || vm.showingDismissAlert ? Color(.gray) : Color("tile"))
                        .bold()
                    Text("Shuffle")
                        .font(Font.custom("Chalkboard SE", size: 18))
                        .frame(minWidth: 80)
                        .foregroundColor(vm.showingCongratulationAlert == true || vm.showingDismissAlert ? Color(.gray) : Color("timerAndMovesButton"))
                }
            })
            .disabled(vm.showingCongratulationAlert == true || vm.showingDismissAlert)
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    Image(systemName: "timer")
                        .font(Font.custom("Chalkboard SE", size: 18))
                        .frame(width: 38)
                        .foregroundColor(Color("tile"))
                    Text("\(vm.formatMmSs(counter: vm.timeElapsed))")
                        .foregroundColor(Color("timerAndMovesButton"))
                        .font(.headline)
                        .frame(width: 70, height: 15)
                }
                HStack(spacing: 0) {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(Font.custom("Chalkboard SE", size: 18))
                        .frame(width: 40)
                        .foregroundColor(Color("tile"))
                    Text("\(vm.totalMoves)")
                        .foregroundColor(Color("timerAndMovesButton"))
                        .font(.headline)
                        .frame(width: 70, height: 15)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 55)
        
    }
}

#Preview {
    GameView(vm: GameVM())
}

