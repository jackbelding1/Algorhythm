import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var spotify: Spotify
    
    var body: some View {
        NavigationView{
            PlaylistsListView()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView().environmentObject(spotify), label: {
                        if let userImage = spotify.currentUser?.images, userImage.count != 0{
                            AsyncImage(url: userImage[0].url, scale: 3.0)
                                  .frame(width: 20, height: 20)
                                  .foregroundColor(.white)
                                  .padding(20)
                                  .clipShape(Circle())
                        }
                        else {
                            Image(systemName: "person.circle")
                        }
                    })
                }
                ToolbarItem(placement: .navigation) {
                    Text("Your Playlists")
                        .font(.system(size: 20))
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                            print("home")
                    }, label: {
                        Image(systemName: "house")
                    })
                    Spacer()
                    NavigationLink(destination: MoodScreen(), label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                    })
                    Spacer()
                    Button(action: {
                            print("booyah")
                    }, label: {
                        Image(systemName: "ellipsis")
                    })
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
