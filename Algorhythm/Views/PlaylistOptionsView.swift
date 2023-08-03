import SwiftUI

struct ParentView: View {
    @State private var isPresenting: Bool = false
    @ObservedObject var playListOptionsViewModel: PlaylistOptionsViewModel
    var shouldLoadOptions: Bool
    
    init(viewModel: PlaylistOptionsViewModel, shouldLoadOptions: Bool) {
        self.playListOptionsViewModel = viewModel
        self.shouldLoadOptions = shouldLoadOptions
    }

    var body: some View {
        PlaylistOptionsView(
            isPresenting: $isPresenting,
            playListOptionsViewModel,
            shouldLoadOptions: false)
    }
}


struct PlaylistOptionsView: View {
    @Binding var isPresenting: Bool
    @State private var playlistOptions: PlaylistOptionsViewModel
    @State private var savePreferences: Bool = false
    @State private var didTapUpdate: Bool = false
    @State private var playlistOptionsCopy: PlaylistOptionsViewModel

    init(isPresenting: Binding<Bool>, _ viewModel: PlaylistOptionsViewModel, shouldLoadOptions loadOptions: Bool) {
        self._isPresenting = isPresenting
        _playlistOptions = State(initialValue: viewModel)
        _playlistOptionsCopy = State(initialValue: PlaylistOptionsViewModel())
        if loadOptions {
            playlistOptions.loadPlaylistOptions()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                CheckboxField(id: "edm",
                              label: "EDM",
                              size: 18,
                              textSize: 18,
                              callback: checkboxSelected,
                              isMarked: playlistOptions.getPreference(withPreference: "edm"))
                CheckboxField(id: "country",
                              label: "Country",
                              size: 18,
                              textSize: 18,
                              callback: checkboxSelected,
                              isMarked: playlistOptions.getPreference(withPreference: "country"))
                CheckboxField(id: "rap",
                              label: "Hip-Hop/Rap",
                              size: 18,
                              textSize: 18,
                              callback: checkboxSelected,
                              isMarked: playlistOptions.getPreference(withPreference: "rap"))
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresenting = false }, label: {Image(systemName: "x.circle")})
                }
                ToolbarItem(placement: .principal) {
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
                        Button(action: {
                            didTapUpdate = true
                            isPresenting = false
                        }, label: {
                            Text("Clear All").underline()
                        } )
                        Spacer()
                        Button(action: {
                            didTapUpdate = true
                            isPresenting = false
                            print("update view model!!!")
                        }){
                            Text("Update")
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
                playlistOptions.makeCopy(from: playlistOptionsCopy)
            }
            else {
                didTapUpdate = false
            }
            if savePreferences {
                playlistOptions.savePlaylistOptions()
            }
            else {
                playlistOptions.defaultPlaylistOptions()
            }
        })
        .onAppear(perform: {
            playlistOptionsCopy.makeCopy(from: playlistOptions)
        })
    }
    
    func checkboxSelected(id: String, isMarked: Bool) {
        if id == "savePreferences" {
            savePreferences = isMarked
        } else {
            playlistOptions.editGenrePreference(forGenre: id, toValue: isMarked)
        }
    }
}

//struct PlaylistOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaylistOptionsView(isPresenting: false, PlaylistOptionsViewModel(), shouldLoadOptions: false)
//    }
//}
