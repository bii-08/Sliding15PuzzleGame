//
//  CustomAlertView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/29.
//

import SwiftUI

struct CustomAlertView: View {
    var title: String
    var message: String
    var primaryButtonTitle: String
    var action1: () -> ()
    var secondaryButtonTitle: String
    var action2: () -> ()
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack {
                Text(title)
                    .font(.custom("Chalkboard SE", size: 30))
                    .bold()
                    .padding()
                    .foregroundColor(Color("excellent"))
                
                Text(message)
                    .font(.custom("Chalkboard SE", size: 20))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                Spacer()
  
                HStack {
                    Button {
                        action1()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 120, height: 50)
                                .foregroundColor(Color.orange)
                            Text(primaryButtonTitle)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                    }

                    Button {
                        action2()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color.orange)
                                .frame(width: 125, height: 50)
                            Text(secondaryButtonTitle)
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 100)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(5)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .padding(30)
        }
    }
}



#Preview {
    CustomAlertView(title: "Confirmation", message: "Are you sure you want to cancel the game?", primaryButtonTitle: "Yes", action1: {}, secondaryButtonTitle: "New Game", action2: {})
    
}
