//
//  MoodScreen.swift
//  Algorhythm
//
//  Created by Jack Belding on 11/6/22.
//

import SwiftUI

struct MoodScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private var symbols = ["keyboard", "hifispeaker.fill", "printer.fill", "tv.fill", "desktopcomputer", "headphones", "tv.music.note", "mic", "plus.bubble", "video"]
    
    private var colors: [Color] = [.yellow, .purple, .green]
    
    private var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 20.0){
            Text("How do you want to feel?")
                .font(.largeTitle)
                .frame(width: 400)
                .foregroundColor(.accentColor)
            Divider()
            Text("Select up to two moods...")
                .font(.title2)
                .foregroundColor(.accentColor)
            ScrollView(.horizontal) {
                LazyHGrid(rows: threeColumnGrid) {
                    ForEach((0...9999), id: \.self) {
                        Image(systemName: symbols[$0 % symbols.count])
                            .font(.system(size: 30))
                            .frame(width: 50, height: 50)
                            .background(colors[$0 % colors.count])
                            .cornerRadius(10)
                    }
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: 60.0, height: 60.0)
                    .foregroundColor(.accentColor)
            }
        })
    }
}

struct MoodScreen_Previews: PreviewProvider {
    static var previews: some View {
        MoodScreen()
    }
}
