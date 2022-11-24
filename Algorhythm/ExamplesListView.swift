import SwiftUI

struct ExamplesListView: View {
    
    @EnvironmentObject var spotify: Spotify
    
    var body: some View {
        NavigationView{
            List{
                NavigationLink("Create a new playlist", destination: MoodScreen())
                NavigationLink("test the algorithm", destination: SpotifyAnalysisScreen(mood: nil)
                    .environmentObject(spotify)
)
            }

        }
        
    }
}

struct ExamplesListView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        NavigationView {
            ExamplesListView()
                .environmentObject(spotify)
        }
    }
}
