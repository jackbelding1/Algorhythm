//
//  MoodScreen.swift
//  Algorhythm
//
//  Created by Jack Belding on 11/6/22.
//

import SwiftUI

struct MoodScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // emojis for mood options
    private let symbols = ["🔥", "🤠", "🌴", "💗", "😈", "😪", "⚡️", "💦"]
    // colors for mood options
    private let colors: [Color] = [.red, .yellow, .green, .pink, .gray,
                                   .blue, .orange, .purple]
    // captions for mood options
    private let captions:[String] = ["Aggressive", "Happy", "Calm", "Romantic", "Dark",
                                     "Sad", "Energetic", "Sexy"]
    // grid options
    private var twoColumnGrid = [GridItem(.flexible(), spacing: 50), GridItem(.flexible(), spacing: 50)]
    
    // selected mood
    @State private var selectedMood:SpotifyAnalysisViewModel.Moods? = nil
    
    // handle tapping of mood option
    private func onTapped(mood:SpotifyAnalysisViewModel.Moods) {
        selectedMood = mood == selectedMood ?
        nil : mood
        print("selected \(mood)")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20.0){
                Text("How are you feeling?")
                    .font(.largeTitle)
                    .frame(width: 370)
                    .foregroundColor(.accentColor)
                    .padding(20)
                Divider()
                    .frame(width: 300, height: 5)
                    .overlay(.gray)
                Text("Select a mood...")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .padding(10)
                LazyHGrid(rows: twoColumnGrid, spacing: 10) {
                    ForEach((0...7), id: \.self) {i in
                        VStack {
                            Button(action: {onTapped(mood: SpotifyAnalysisViewModel.Moods.allCases[i])}){
                                Text(symbols[i])
                                    .font(.system(size: 50))
                                    .frame(width: 65, height: 85)
                                    .background(colors[i])
                                    .cornerRadius(40)
                            }
                            .overlay(selectedMood == SpotifyAnalysisViewModel.Moods.allCases[i]
                                ? RoundedRectangle(cornerRadius: 5)
                                .stroke(.green) : nil)
                            Text(captions[i])
                            .font(.system(size: 10))
                        }
                    }
                }
                .frame(height:300)
                Spacer()
                if selectedMood != nil {
                    NavigationLink(destination: SpotifyAnalysisScreen(mood: selectedMood)){
                        Image(systemName: "arrow.right.circle")
                            .frame(height:200)
                        Text("Continue")
                    }
                }
                else {
                    Spacer()
                        .frame(height:200)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 45.0, height: 45.0)
                        .foregroundColor(.accentColor)
                }
            })
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MoodScreen_Previews: PreviewProvider {
    static var previews: some View {
        MoodScreen().preferredColorScheme(.dark)
    }
}
