//
//  SpotifyPlaylistsListViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/16/23.
//

import Foundation
import SpotifyWebAPI

class SpotifyPlaylistsListViewModel: ObservableObject {
    @Published var playlists: [Playlist<PlaylistItemsReference>] = []
    @Published var isLoadingPlaylists = false
    @Published var couldntLoadPlaylists = false
    @Published var alert: AlertItem? = nil

    private var repository: SpotifyRepository
    private var algoDbManager = AlgoDataManager()

    init(spotify: Spotify) {
        repository = SpotifyRepository(spotify: spotify)
    }

    func delete(at offsets: IndexSet) {
        let playlistToDelete = playlists[offsets[offsets.startIndex]]
        algoDbManager.deletePlaylist(withId: playlistToDelete.id) // delete from local storage
        repository.deletePlaylist(withId: playlistToDelete.id) { result in // delete from spotify
            switch result {
            case .success:
                print("playlist deleted from spotify")
            case .failure(let error):
                print("couldn't delete playlist")
                self.alert = AlertItem(
                    title: "Couldn't delete playlist from spotify",
                    message: error.localizedDescription
                )
            }
        }
        playlists.remove(atOffsets: offsets)
    }

    func retrievePlaylists() {
        if ProcessInfo.processInfo.isPreviewing { return }

        let idsToLoad = algoDbManager.readCreatedPlaylists()
        self.isLoadingPlaylists = true
        self.playlists = []

        repository.retrievePlaylists(idsToLoad: idsToLoad) { result in
            switch result {
            case .success(let playlists):
                self.playlists.append(contentsOf: playlists)
            case .failure(let error):
                self.couldntLoadPlaylists = true
                self.alert = AlertItem(
                    title: "Couldn't Retrieve Playlists",
                    message: error.localizedDescription
                )
            }
            self.isLoadingPlaylists = false
        }
    }
}
