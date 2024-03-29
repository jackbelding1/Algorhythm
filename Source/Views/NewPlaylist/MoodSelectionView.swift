import SwiftUI

// MARK: - MoodSelectionView
struct MoodSelectionView: View {
    
    // MARK: - Constants
    private let moodOptionsGrid = [GridItem(.flexible(), spacing: 50), GridItem(.flexible(), spacing: 50)]
    private let moodButtonSize = CGSize(width: 65, height: 85)
    private let navButtonSize = CGSize(width: 20.0, height: 20.0)
    
    // MARK: - Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var newPlaylistViewModel = NewPlaylistViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20.0) {
                Spacer(minLength: 30)
                MoodHeader()
                MoodSelectionGrid(
                    viewModel: newPlaylistViewModel,
                    moodOptionsGrid: moodOptionsGrid,
                    moodButtonSize: moodButtonSize
                )
                MoodConfirmation(
                    viewModel: newPlaylistViewModel
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: DismissButton(navButtonSize: navButtonSize),
            trailing: PreferencesButton(viewModel: newPlaylistViewModel,
                                        navButtonSize: navButtonSize)
        )        .sheet(isPresented: $newPlaylistViewModel.isPresenting) {
            PlaylistOptionsView(
                newPlaylistViewModel,
                shouldLoadOptions: newPlaylistViewModel.savePreferences
            )
        }
    }
    
    // MARK: - View Helpers
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
        @ObservedObject var viewModel: NewPlaylistViewModel
        let moodOptionsGrid: [GridItem]
        let moodButtonSize: CGSize

        init(viewModel: NewPlaylistViewModel, moodOptionsGrid: [GridItem], moodButtonSize: CGSize) {
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
        @ObservedObject var viewModel: NewPlaylistViewModel
        @EnvironmentObject var spotify: Spotify

        var body: some View {
            if let selectedMood = viewModel.selectedMood {
                NavigationLink(destination:
                    SpotifyAnalysisScreen(viewModel,
                    withViewModel: SpotifyAnalysisViewModel(
                    spotify: spotify, withMood: selectedMood,
                    withGenre: viewModel.getRandomGenreKey() ?? "edm"
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
    
    // MARK: - Buttons
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
        @ObservedObject var viewModel: NewPlaylistViewModel
        let navButtonSize: CGSize

        init(viewModel: NewPlaylistViewModel, navButtonSize: CGSize) {
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
