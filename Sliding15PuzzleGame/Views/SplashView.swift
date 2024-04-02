//
//  SlashView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/15.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isActive = false
    @State private var size = 0.5
    @State private var opacity = 0.95
    var body: some View {
        if isActive {
            GameSelectionView()
        } else {
            ZStack {
                Color("splash")
                    .ignoresSafeArea()
                VStack {
                    if colorScheme == .light {
                        Image("Puzzle icon_Light mode")
                            .resizable()
                            .frame(width: 350,height: 150)
                    } else {
                        Image("Puzzle icon_Dark mode")
                            .resizable()
                            .frame(width: 350,height: 150)
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
