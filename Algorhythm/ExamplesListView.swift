import SwiftUI

struct ExamplesListView: View {
    
    var body: some View {
        NavigationView{
            List{
                NavigationLink("Create a new playlist", destination: MoodScreen())
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
