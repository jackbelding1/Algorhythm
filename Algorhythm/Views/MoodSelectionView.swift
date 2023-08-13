import SwiftUI

struct MoodSelectionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var moodSelectionViewModel = MoodSelectionViewModel()
    @StateObject private var playlistOptions = PlaylistOptionsViewModel()

    
    private let moodOptionsGrid = [GridItem(.flexible(), spacing: 50), GridItem(.flexible(), spacing: 50)]
    private let moodButtonSize = CGSize(width: 65, height: 85)
    private let navButtonSize = CGSize(width: 20.0, height: 20.0)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20.0) {
                Spacer(minLength: 30)
                MoodHeader()
                MoodSelectionGrid(
                    viewModel: moodSelectionViewModel, moodOptionsGrid: moodOptionsGrid,
                    moodButtonSize: moodButtonSize)
                MoodConfirmation(viewModel: moodSelectionViewModel, playlistOptions: playlistOptions)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: DismissButton(navButtonSize: navButtonSize),
                trailing: PreferencesButton(viewModel: moodSelectionViewModel,
                                            navButtonSize: navButtonSize)
)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $moodSelectionViewModel.isPresenting) {
            PlaylistOptionsView(playlistOptions,
                                shouldLoadOptions: moodSelectionViewModel.savePreferences
        )}
    }
    
    private struct MoodHeader: View {
        var body: some View {
            Text("How are you feeling?")
                .font(.title)
                .frame(width: 370)
                .foregroundColor(.accentColor)
            Divider()
                .frame(width: 300, height: 3)
                .background(.gray)
            Text("Select a mood...")
                .font(.title2)
                .foregroundColor(.accentColor)
                .padding(10)
        }
    }
    
    private struct MoodSelectionGrid: View {
        @ObservedObject var viewModel: MoodSelectionViewModel
        
        let moodOptionsGrid: [GridItem]
        let moodButtonSize: CGSize

        init(viewModel: MoodSelectionViewModel, moodOptionsGrid: [GridItem], moodButtonSize: CGSize) {
            self.viewModel = viewModel
            self.moodOptionsGrid = moodOptionsGrid
            self.moodButtonSize = moodButtonSize
        }
        
        var body: some View {
            LazyHGrid(rows: moodOptionsGrid, spacing: 10) {
                ForEach(viewModel.moodOptions, id: \.caption) { moodOption in
                    VStack {
                        Button(action: { viewModel.moodOptionTapped(mood: moodOption.caption.lowercased()) }) {
                            Text(moodOption.emoji)
                                .font(.system(size: 50))
                                .frame(width: moodButtonSize.width, height: moodButtonSize.height)
                                .background(moodOption.color)
                                .cornerRadius(40)
                        }
                        .overlay(viewModel.selectedMood == moodOption.caption.lowercased()
                                 ? RoundedRectangle(cornerRadius: 5).stroke(.green) : nil)
                        Text(moodOption.caption)
                            .font(.system(size: 10))
                    }
                }
            }
            .frame(height: 300)
            Spacer()
        }
    }
    
    private struct MoodConfirmation: View {
        @ObservedObject var viewModel: MoodSelectionViewModel
        @ObservedObject var playlistOptions:PlaylistOptionsViewModel
        @EnvironmentObject var spotify: Spotify
        
        var body: some View {
            if let selectedMood = viewModel.selectedMood {
                NavigationLink(destination: SpotifyAnalysisScreen(
                    mood: selectedMood, viewModel.playlistOptions,
                    withViewModel: SpotifyAnalysisViewModel(
                        spotify: spotify, withMood: selectedMood,
                        withGenre: playlistOptions.getRandomGenreKey() ?? "edm"
                    ))) {
                    Image(systemName: "arrow.right.circle")
                        .frame(height: 200)
                    Text("Continue")
                }
            } else {
                Spacer().frame(height: 200)
            }
        }
    }
    
    private struct DismissButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        let navButtonSize: CGSize

        init(navButtonSize: CGSize) {
            self.navButtonSize = navButtonSize
        }
        
        var body: some View {
            Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: navButtonSize.width, height: navButtonSize.height)
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private struct PreferencesButton: View {
        @ObservedObject var viewModel: MoodSelectionViewModel
            let navButtonSize: CGSize

            init(viewModel: MoodSelectionViewModel, navButtonSize: CGSize) {
                self.viewModel = viewModel
                self.navButtonSize = navButtonSize
            }
        
        var body: some View {
            Button(action: { viewModel.isPresenting = true }) {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: navButtonSize.width, height: navButtonSize.height)
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    struct MoodScreen_Previews: PreviewProvider {
        static var previews: some View {
            MoodSelectionView().preferredColorScheme(.dark)
        }
    }
}
