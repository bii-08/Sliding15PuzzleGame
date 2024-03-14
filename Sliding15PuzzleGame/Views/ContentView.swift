//
//  ContentView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView(size: 4, tileSize: 80, bestPlay: [10_000_000])
    }
     
}

#Preview {
    ContentView()
}
