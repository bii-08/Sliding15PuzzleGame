//
//  PicturesView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/28.
//

import SwiftUI
import PhotosUI

struct PicturesListView: View {
    @State private var pictures: [Picture] = Picture.allCases
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
                        ZStack(alignment: .topTrailing) {
                            Image("\(pictures[index])")
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 200)
                                .cornerRadius(10)
                                .shadow(color: Color.primary.opacity(0.3), radius: 1)
                            if pictures[index].isJustAdded {
                                Text("New")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                                    .offset(x: -16, y: 16)
                            }
                        }
                    }
                    
                }
            }
        }
    }
}



#Preview {
    PicturesListView(gridLayout: [GridItem()], action: {_ in })
}
