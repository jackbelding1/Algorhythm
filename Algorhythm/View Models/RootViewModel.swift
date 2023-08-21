//
//  RootViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/20/23.
//

import Foundation

class RootViewModel: ObservableObject {
    private var spotifyRepository: SpotifyRepository
    
    @Published var alert: AlertItem? = nil
    
    init(spotify: Spotify) {
        self.spotifyRepository = SpotifyRepository(spotify: spotify)
    }
    
    func handleURL(_ url: URL) {
        spotifyRepository.handleURL(url) { [weak self] alertItem in
            self?.alert = alertItem
        }
    }
}
