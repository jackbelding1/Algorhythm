//
//  PlaylistCellViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/17/23.
//
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

// MARK: - PlaylistCellViewModel
class PlaylistCellViewModel: ObservableObject {
    // MARK: - Variables
    private var playlist: Playlist<PlaylistItemsReference>
    private var cancellables = Set<AnyCancellable>()
    private var repository: SpotifyRepository
    @Published var didRequestImage = false

    // MARK: - Initializer
    init(spotify: Spotify, playlist: Playlist<PlaylistItemsReference>) {
        self.repository = SpotifyRepository(spotify: spotify)
        self.playlist = playlist
    }

    // MARK: - Public Functions
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
