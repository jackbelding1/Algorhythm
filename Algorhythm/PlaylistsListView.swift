//
//  PlaylistsListView.swift
//  Algorhythm
//
//  Created by Jack Belding on 12/23/22.
//

import SwiftUI
import Combine
import SpotifyWebAPI

// the URI for artists
class playlistURI: SpotifyURIConvertible {
    public var uri:String
    
    init(URI playlistUri:String){
        self.uri = "spotify:playlist:\(playlistUri)"
    }
}


struct PlaylistsListView: View {
    
    @EnvironmentObject var spotify: Spotify

    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false
    
    @State private var alert: AlertItem? = nil
    
    private let algoDbManager = AlgoDataManager()

    init() { }
    
    /// Used only by the preview provider to provide sample data.
    fileprivate init(samplePlaylists: [Playlist<PlaylistItemsReference>]) {
        self._playlists = State(initialValue: samplePlaylists)
    }
    
    var body: some View {
        VStack {
            if playlists.isEmpty {
                if isLoadingPlaylists {
                    HStack {
                        ProgressView()
                            .padding()
                        Text("Loading Playlists")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                else if couldntLoadPlaylists {
                    Text("Couldn't Load Playlists")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                else {
                    Text("No Playlists Found")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            else {
                List {
                    ForEach(playlists, id: \.uri) { playlist in
                        PlaylistCellView(spotify: spotify, playlist: playlist)
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(PlainListStyle())
                .accessibility(identifier: "Playlists List View")
                .padding(.top, 20)
            }
        }
        .navigationBarItems(trailing: refreshButton)
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .onAppear(perform: retrievePlaylists)
        
    }
    
    func delete(at offsets: IndexSet) {
        let playlistToDelete = playlists[offsets[offsets.startIndex]]
        algoDbManager.deletePlaylist(withId: playlistToDelete.id)
        deletePlaylist(withId: playlistToDelete.id)
        playlists.remove(atOffsets: offsets)
    }
    
    var refreshButton: some View {
        Button(action: retrievePlaylists) {
            Image(systemName: "arrow.clockwise")
                .font(.title)
                .scaleEffect(0.8)
                .frame(height: 30)

        }
        .disabled(isLoadingPlaylists)
        
    }

    func deletePlaylist(withId Id:String) {
        spotify.api.unfollowPlaylistForCurrentUser(playlistURI(URI: Id))
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("playlist deleted from spotify")
                    case .failure(let error):
                        print("couldnt delete playlist")
                        self.alert = AlertItem(
                            title: "Couldn't delete playlist from spotify",
                            message: error.localizedDescription
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func retrievePlaylists() {
        
        // Don't try to load any playlists if we're in preview mode.
        if ProcessInfo.processInfo.isPreviewing { return }

        let idsToLoad = algoDbManager.readCreatedPlaylists()
        self.isLoadingPlaylists = true
        self.playlists = []
        spotify.api.currentUserPlaylists(limit: 50)
            // Gets all pages of playlists.
            .extendPages(spotify.api)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingPlaylists = false
                    switch completion {
                        case .finished:
                            self.couldntLoadPlaylists = false
                        case .failure(let error):
                            self.couldntLoadPlaylists = true
                            self.alert = AlertItem(
                                title: "Couldn't Retrieve Playlists",
                                message: error.localizedDescription
                            )
                    }
                },
                // We will receive a value for each page of playlists. You could
                // use Combine's `collect()` operator to wait until all of the
                // pages have been retrieved.
                receiveValue: { playlistsPage in
                    let playlists = playlistsPage.items.filter {idsToLoad.contains($0.id)}
                    self.playlists.append(contentsOf: playlists)
                }
            )
            .store(in: &cancellables)
    }
}

struct PlaylistsListView_Previews: PreviewProvider {
    
    static let spotify = Spotify()
    
    static let playlists: [Playlist<PlaylistItemsReference>] = [
        .menITrust, .modernPsychedelia, .menITrust,
        .lucyInTheSkyWithDiamonds, .rockClassics,
        .thisIsMFDoom, .thisIsSonicYouth, .thisIsMildHighClub,
        .thisIsSkinshape
    ]
    
    static var previews: some View {
        NavigationView {
            PlaylistsListView(samplePlaylists: playlists)
                .environmentObject(spotify)
        }
    }
}
