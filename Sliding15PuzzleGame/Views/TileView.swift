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
    let picture: Picture?
    let onTap: () -> Void
    var showingHint: Bool?
    
    var body: some View {
        ZStack {
            if number == 0 {
                Color.gray.opacity(0.3)
            } else {
                Color("tile")
                if let picture, let showingHint {
                    Image("\(picture.rawValue)_\(number)")
                        .resizable()
                        .overlay(showingHint ? showOrHide : nil)
                } else {
                    Text("\(number)")
                        .font(.system(size: CGFloat(size) * 0.6))
                        .bold()
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}
extension TileView {
    private var showOrHide: some View {
        VStack {
            Spacer()
            HStack {
                ZStack {
                    Circle().opacity(0.45)
                    Text("\(number)")
                        .font(.title2)
                        .foregroundColor(.red)
                        .bold()
                }
                .frame(width: 32, height: 32)
                Spacer()
            }
        }
    }
}

#Preview {
    TileView(number: 8, size: 45, picture: nil, onTap: {})
}
