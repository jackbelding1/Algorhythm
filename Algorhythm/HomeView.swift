import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var spotify: Spotify
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Tap below to create a playlist!")
                Image(systemName: "arrow.down")
                    .frame(width: 60, height: 120)
                    .scaledToFill()

            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                            print("booyah")
                    }, label: {
                        if let userImage = spotify.currentUser?.images![0] {
                            AsyncImage(url: userImage.url, scale: 3.0)
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
                        .font(.title)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                            print("home")
                    }, label: {
                        Image(systemName: "magnifyingglass")
                    })
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
        }
        .navigationBarBackButtonHidden(true)
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
