//
//  MoodScreen.swift
//  Algorhythm
//
//  Created by Jack Belding on 11/6/22.
//

import SwiftUI

struct MoodScreen: View {
    // bool variable to check if the playlist options should be updated
    @State private var didTapUpdate:Bool = false
    // a copy of the preferences in case the user dismisses the view wihtout tapping 'update'
    @State private var playlistOptionsCopy:PlaylistOptionsViewModel = PlaylistOptionsViewModel()
    // the object containing the playlist preferences and options
    @State private var playlistOptions:PlaylistOptionsViewModel = PlaylistOptionsViewModel()
    // if the playlist options should be saved
    @AppStorage("savePreferences")private var savePreferences = false
    // presenting the playlist options pop over
    @State var isPresenting: Bool = false
    //
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
                Spacer(minLength: 30)
                Text("How are you feeling?")
                    .font(.title)
                    .frame(width: 370)
                    .foregroundColor(.accentColor)
                Divider()
                    .frame(width: 300, height: 3)
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
                    NavigationLink(destination: SpotifyAnalysisScreen(mood: selectedMood, playlistOptions)
                    ){
                        Image(systemName: "arrow.right.circle")
                            .frame(height: 200)
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
                        .frame(width: 20.0, height: 20.0)
                        .foregroundColor(.accentColor)
                }
            }, trailing:
                Button(action: {
                    isPresenting = true
            }){
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 20.0, height: 20.0)
                    .foregroundColor(.accentColor)
            }
            )
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isPresenting) {
            NavigationView {
                PlaylistOptionsView(playlistOptions, shouldLoadOptions: savePreferences)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { isPresenting = false }, label: {Image(systemName: "x.circle")} )
                    }
                    ToolbarItem(placement: .principal ) {
                        Text("Preferences")
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CheckboxField(id: "savePreferences",
                                                   label: "Save",
                                                   size: 16,
                                                   textSize: 14,
                                                   callback: checkboxSelected,
                                                   isMarked: savePreferences)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: { print("restore default preferences in view model") }, label: {
                                Text("Clear All")
                                    .underline()
                            } )
                            Spacer()
                            Button(action: {
                                didTapUpdate = true
                                isPresenting = false
                                print("update view model!!!")
                            }){ Text("Update")
                                .foregroundColor(Color.primary).colorInvert()
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                                .font(Font.headline.weight(.bold))
                                .lineLimit(1)
                            }
                            .background(Color.primary)
                            .clipShape(Capsule())
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                    }
                }
            }
            .onDisappear(perform: {
                if !didTapUpdate {
                    playlistOptions.makeCopy(from: playlistOptionsCopy) // restore playlist options
                }
                else {
                    didTapUpdate = false
                }
                if savePreferences {
                    playlistOptions.savePlaylistOptions()
                }
                else {
                    // restore database preferences to default
                    playlistOptions.defaultPlaylistOptions()
                }
            })
            .onAppear(perform: {
                playlistOptionsCopy.makeCopy(from: playlistOptions)  // create copy of playlist options
            })
        }
    }
    func checkboxSelected(id: String, isMarked: Bool) {
        savePreferences = isMarked
    }
    
    struct CustomCheckboxBar<Center>: View where Center: View {
        let center: () -> Center
        init(@ViewBuilder center: @escaping () -> Center) {
            self.center = center
        }
        var body: some View {
            HStack {
                Spacer(minLength: 90.0)
                center()
                
            }
        }
    }
}

struct MoodScreen_Previews: PreviewProvider {
    static var previews: some View {
        MoodScreen().preferredColorScheme(.dark)
    }
}
