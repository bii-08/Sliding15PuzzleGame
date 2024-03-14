//
//  DialogView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/13.
//

import SwiftUI

struct DialogView: View {
    @Binding var isShowingAlert: Bool

       let title: String
       let message: String
       let buttonTitle: String
       let action: () -> ()
       @State private var offset: CGFloat = 1000

       var body: some View {
               VStack {
                   Text(title)
                       .font(.custom("Bradley Hand", size: 40))
                       .bold()
                       .padding()
                       .foregroundColor(Color("excellent"))

                   Text(message)
                       .font(.headline)
                       .foregroundColor(.white)

                   Button {
                      action()
                      close()
                   } label: {
                       ZStack {
                           RoundedRectangle(cornerRadius: 20)
                               .foregroundColor(Color("dialogButton"))
                           Text(buttonTitle)
                               .font(.system(size: 16, weight: .bold))
                               .foregroundColor(.white)
                               .padding()
                       }
                       .padding()
                   }
               }
               .fixedSize(horizontal: false, vertical: true)
               .padding()
               .background(Color("dialog"))
               .clipShape(RoundedRectangle(cornerRadius: 20))
               .shadow(radius: 20)
               .padding(30)
               .offset(x: 0, y: offset)
               .onAppear {
                   withAnimation(.spring()) {
                       offset = 0
                   }
               }
          
       }

       func close() {
           withAnimation(.spring()) {
               offset = 1000
               isShowingAlert = false
           }
       }
   }


#Preview {
    DialogView(isShowingAlert: .constant(true), title: "Excellent!", message: "I took you 121 moves", buttonTitle: "New Game", action: {})
}
