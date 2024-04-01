//
//  GameSelectionView.swift
//  Sliding15PuzzleGame
//
//  Created by LUU THANH TAM on 2024/03/28.
//

import SwiftUI

struct GameSelectionView: View {

    @Environment(\.colorScheme) var colorScheme
    @State var showingSheet = false
    @State var showingGame = false
    @State var showingPictureGame = false
    @State var selectedPicture: Picture?
    @State var isShowingContinueAlert = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background")
                    .ignoresSafeArea()
                
              //   This is an alert asking the user for confirmation on whether they want to CONTINUE the previous game or not.
                if isShowingContinueAlert {
                    CustomAlertView(title: "Confirmation", message: "Do you want to continue?", primaryButtonTitle: "Yes", action1: {
                        showingGame = true
                        isShowingContinueAlert = false
                        
                    }, secondaryButtonTitle: "New Game") {
                        UserDefaults.standard.removeObject(forKey: "savedProgress")
                        withAnimation {
                            isShowingContinueAlert = false
                        }
                    }
                    .zIndex(5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                }
                
                VStack(alignment:.leading) {
                    Spacer()
                    if colorScheme == .light {
                        Image("Puzzle icon_Light mode")
                            .resizable()
                            .frame(width: 200,height: 100)
                    } else {
                        Image("Puzzle icon_Dark mode")
                            .resizable()
                            .frame(width: 200,height: 100)
                    }
                    Spacer()
                    
                    HStack {
                        Button {
                            self.showingGame.toggle()
                        } label: {
                            Text("Classic")
                                .font(Font.custom("Chalkboard SE", size: 25))
                                .padding()
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color.white)
                                .background(Color("classicAndPicture"))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding()
                        
                        Button {
                            self.showingSheet.toggle()
                        } label: {
                            Text("Picture")
                                .font(Font.custom("Chalkboard SE", size: 25))
                                .padding()
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color.white)
                                .background(Color("classicAndPicture"))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    .navigationDestination(isPresented: $showingGame, destination: {
                        GameView(vm: GameVM())
                    })
                    .navigationDestination(isPresented: $showingPictureGame, destination: {
                        GameView(vm: GameVM(picture: selectedPicture))
                    })
                    
                    Spacer()
                    Spacer()
                    Spacer()
                }
            }
            .onAppear {
                if UserDefaults.standard.data(forKey: "savedProgress") != nil {
                    isShowingContinueAlert = true
                }
            }
            
        }
        .sheet(isPresented: $showingSheet) {
            HStack {
                Text("Select a picture")
                    .font(Font.custom("Chalkboard SE", size: 20))
                    .padding(10)
                    .bold()
                Spacer()
                Button {
                    self.showingSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primary)
                }
            }
            .padding(.horizontal)
            
            PicturesListView { picture in
                self.selectedPicture = picture
                showingPictureGame = true
                showingSheet.toggle()
            }
            .presentationBackground(.thinMaterial)
            .presentationCornerRadius(15)
        }
        
    }
}


#Preview {
    NavigationStack {
        GameSelectionView()
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
