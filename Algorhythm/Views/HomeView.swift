import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var spotify: Spotify
    
    private var currentUserImage: some View {
        if let userImage = spotify.currentUser?.images, !userImage.isEmpty {
            return AnyView(
                AsyncImage(url: userImage[0].url, scale: 3.0)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(20)
                    .clipShape(Circle())
            )
        } else {
            return AnyView(Image(systemName: "person.circle"))
        }
    }
    
    private var homeButton: some View {
        Button(action: {
            print("home")
        }) {
            Image(systemName: "house")
        }
    }
    
    private var moodScreenLinkImage: some View {
        Image(systemName: "plus.circle.fill")
            .resizable()
            .scaledToFill()
            .frame(width: 60, height: 60)
    }
    
    private var ellipsisButton: some View {
        Button(action: {
            print("booyah")
        }) {
            Image(systemName: "ellipsis")
        }
    }
    
    var body: some View {
        NavigationView{
            PlaylistsListView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: SettingsView().environmentObject(spotify)) {
                            currentUserImage
                        }
                    }
                    ToolbarItem(placement: .navigation) {
                        Text("Your Playlists")
                            .font(.system(size: 20))
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        homeButton
                        Spacer()
                        NavigationLink(destination: MoodSelectionView()) {
                            moodScreenLinkImage
                        }
                        Spacer()
                        ellipsisButton
                    }
                }
                .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
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
            HomeView()
                .environmentObject(spotify)
        }
    }
}
