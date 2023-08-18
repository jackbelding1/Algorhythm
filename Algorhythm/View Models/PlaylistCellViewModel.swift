//
//  PlaylistCellViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/17/23.
//

import Foundation
import Combine
import SpotifyWebAPI
import SwiftUI // TODO: REPLACE WITH DEPENDENCY INJECTION


class PlaylistCellViewModel: ObservableObject {
    private var playlist: Playlist<PlaylistItemsReference>
    private var cancellables = Set<AnyCancellable>()
    private var repository: SpotifyRepository

    // Image loading states
    @Published var didRequestImage = false

    init(spotify: Spotify, playlist: Playlist<PlaylistItemsReference>) {
        self.repository = SpotifyRepository(spotify: spotify)
        self.playlist = playlist
    }

    func loadImage(completion: @escaping (Image?) -> Void) {
        if self.didRequestImage {
            return
        }
        self.didRequestImage = true

        repository.loadImage(forPlaylist: playlist) { data in
            completion(data)
        }
    }
    
    func getPlaylistName() -> String { playlist.name }

    func openPlaylist() -> URL? {
        repository.openPlaylistURL(playlistId: playlist.id)
    }
}
