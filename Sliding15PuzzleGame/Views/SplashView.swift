//
//  SlashView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/15.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    var body: some View {
        if isActive {
           GameSelectionView()
        } else {
            ZStack {
                Color("splash")
                    .ignoresSafeArea()
                LottieView(name: "puzzle", loopMode: .loop)
                    .frame(width: 230, height: 180)
            }
            .onAppear {
                withAnimation(.easeInOut){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
