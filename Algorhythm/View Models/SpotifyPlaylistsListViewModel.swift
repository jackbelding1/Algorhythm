//
//  SpotifyPlaylistsListViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/16/23.
//

import Foundation
import SpotifyWebAPI

// MARK: - SpotifyPlaylistsListViewModel
class SpotifyPlaylistsListViewModel: ObservableObject {
    // MARK: - Variables
    @Published var playlists: [Playlist<PlaylistItemsReference>] = []
    @Published var isLoadingPlaylists = false
    @Published var couldntLoadPlaylists = false
    @Published var alert: AlertItem? = nil

    internal var spotifyRepository: SpotifyRepositoryProtocol
    internal var realmRepository: RealmRepositoryProtocol

    // MARK: - Initializer
    init(spotify: Spotify) {
        spotifyRepository = SpotifyRepository(spotify: spotify)
        realmRepository = RealmRepository()
    }

    // MARK: - Handlers
    func delete(at offsets: IndexSet) {
        let playlistToDelete = playlists[offsets[offsets.startIndex]]
        deletePlaylistFromLocalStorage(playlistId: playlistToDelete.id)
        deletePlaylistFromSpotify(playlistId: playlistToDelete.id)
        playlists.remove(atOffsets: offsets)
    }

    func retrievePlaylists() {
        guard !ProcessInfo.processInfo.isPreviewing else { return }

        let idsToLoad = realmRepository.readCreatedPlaylists()
        isLoadingPlaylists = true
        playlists = []

        spotifyRepository.retrievePlaylists(idsToLoad: idsToLoad) { result in
            self.handleRetrievePlaylistsResult(result)
        }
    }

    // MARK: - Private Methods
    private func deletePlaylistFromLocalStorage(playlistId: String) {
        realmRepository.deletePlaylist(withId: playlistId)
    }

    private func deletePlaylistFromSpotify(playlistId: String) {
        spotifyRepository.deletePlaylist(withId: playlistId) { result in
            self.handleDeletePlaylistResult(result)
        }
    }

    private func handleDeletePlaylistResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            print("playlist deleted from spotify")
        case .failure(let error):
            alert = AlertItem(
                title: "Couldn't delete playlist from Spotify",
                message: error.localizedDescription
            )
        }
    }

    private func handleRetrievePlaylistsResult(_ result: Result<[Playlist<PlaylistItemsReference>], Error>) {
        switch result {
        case .success(let playlists):
            self.playlists.append(contentsOf: playlists)
        case .failure(let error):
            couldntLoadPlaylists = true
            alert = AlertItem(
                title: "Couldn't Retrieve Playlists",
                message: error.localizedDescription
            )
        }
        isLoadingPlaylists = false
    }
}
