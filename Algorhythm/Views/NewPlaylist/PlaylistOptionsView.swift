import SwiftUI

struct PlaylistOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var playlistOptions: NewPlaylistViewModel
    
    init(_ viewModel: NewPlaylistViewModel, shouldLoadOptions loadOptions: Bool) {
        _playlistOptions = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack{
                ForEach($playlistOptions.genrePreferencesCollection, id: \.key) { $genre in
                    CheckboxField(id: genre.key,
                                  label: genre.title,
                                  size: 18,
                                  textSize: 18,
                                  callback: checkboxSelected,
                                  isMarked: genre.value)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismissTapped) {
                        Image(systemName: "x.circle")
                    }
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
                                  isMarked: playlistOptions.savePreferences)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: playlistOptions.clearGenreSelections) {
                            Text("Clear All").underline()
                        }
                        Spacer()
                        Button(action: updateAction) {
                            Text("Update")
                                .foregroundColor(Color.primary).colorInvert()
                                .padding(20)
                                .font(Font.headline.weight(.bold))
                        }
                        .background(Color.primary)
                        .clipShape(Capsule())
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                    }
                }
            }
        }
    }
    
    private func updateAction() {
        playlistOptions.handleTapUpdate()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func dismissTapped() {
        playlistOptions.restorePreferences()
        presentationMode.wrappedValue.dismiss()
    }
    
    func checkboxSelected(id: String, isMarked: Bool) {
        if id == "savePreferences" {
            playlistOptions.updateSavePreferences(isMarked: isMarked)
        } else {
            playlistOptions.updateGenreSelection(id: id, isMarked: isMarked)
        }
    }
}
