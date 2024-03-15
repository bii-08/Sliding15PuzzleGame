//
//  TileView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/11.
//

import SwiftUI

struct TileView: View {
    let number: Int
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            if number == 0 {
                Color.gray.opacity(0.3)
            } else {
                Color("tile")
                Text("\(number)")
                    .font(.system(size: CGFloat(size) * 0.6))
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    TileView(number: 8, size: 50, onTap: {})
}
