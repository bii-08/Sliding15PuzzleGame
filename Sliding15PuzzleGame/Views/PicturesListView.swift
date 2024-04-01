//
//  PicturesView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/28.
//

import SwiftUI
import PhotosUI

struct PicturesListView: View {
    @State private var pictures: [Picture] = [Picture.boyAndCat, Picture.eating, Picture.fly, Picture.japaneseHouse, Picture.maxAndJess, Picture.pancake, Picture.temple, Picture.udonYa]
    @State var gridLayout: [GridItem] = [GridItem()]
    var action: (Picture) -> Void
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 10) {
                ForEach(0..<pictures.count, id: \.self) { index in
                    Button {
                        // Todo: Cancel the sheet and navigate user to Game View
                        action(pictures[index].id)
                    } label: {
                        Image("\(pictures[index])")
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(color: Color.primary.opacity(0.3), radius: 1)
                    }
                    
                }
            }
        }
    }
}



#Preview {
    PicturesListView(gridLayout: [GridItem()], action: {_ in })
}
