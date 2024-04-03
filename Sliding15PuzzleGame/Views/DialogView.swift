//
//  DialogView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/13.
//

import SwiftUI

struct DialogView: View {
    @Binding var isShowingAlert: Bool
    @State var play = true // confetti
    let title: String
    let message: String
    let bestPlay: Int
    let buttonTitle: String
    let action: () -> ()
       @State private var offset: CGFloat = 1000
    
       var body: some View {
           ZStack {
               VStack {
                       Text(title) // Text 'Excellent!'
                       .font(.custom("Chalkboard SE", size: 35))
                           .bold()
                           .padding()
                           .foregroundColor(Color("excellent"))

                   Text(message) // Text 'It took you 121 moves'
                       .font(.custom("Chalkboard SE", size: 20))
                       .foregroundColor(.white)
                   Spacer()
                
                       if bestPlay > 0 {
                           HStack {
                               Image(systemName: "crown.fill")
                                   .foregroundColor(.yellow)
                               Text("Best play:" + " " + String(bestPlay) ) // Text 'Best play: 20'
                                   .font(.custom("Chalkboard SE", size: 20))
                                   .foregroundColor(Color.yellow)
                           }
                       }
                       // Button 'New Game'
                       Button {
                          action()
                          close()
                       } label: {
                           ZStack {
                               RoundedRectangle(cornerRadius: 20)
                                   .foregroundColor(Color.orange)
                               Text(buttonTitle)
//                                   .font(.custom("Chalkboard SE", size: 20))
                                   .font(.system(size: 18, weight: .bold))
                                   .foregroundColor(.white)
                                   .padding()
                           }
                           .padding()
                       }
                   }
                   .fixedSize(horizontal: false, vertical: true)
                   .padding()
                   .background(.ultraThinMaterial)
                   .clipShape(RoundedRectangle(cornerRadius: 20))
                   .overlay(alignment: .topTrailing) {
                       Button {
                           close()
                       } label: {
                           Image(systemName: "xmark")
                               .font(.title2)
                               .fontWeight(.medium)
                       }
                       .tint(.white)
                       .bold()
                       .padding()
                   }
                   .shadow(radius: 10)
                   .padding(30)
                   .offset(x: 0, y: offset)
                   .onAppear {
                       withAnimation(.spring()) {
                           offset = 0
                       }
               }
               LottieView(name: "Confetti", contentMode: .scaleAspectFill, play: $play)
                   .allowsHitTesting(false)
           }
           .onDisappear {
               play = false
           }
           .ignoresSafeArea()
       }
      
     // FUNCTION: function to close dialog
       private func close() {
           withAnimation(.spring()) {
               offset = 1000
               isShowingAlert = false
           }
       }
   }

#Preview {
    DialogView(isShowingAlert: .constant(true), title: "Excellent!", message: "It took you 121 moves", bestPlay: 20, buttonTitle: "New Game", action: {})
}
