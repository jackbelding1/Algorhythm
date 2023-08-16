//
//  SpotifyPlaylistsRepository.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/16/23.
//

import Foundation
import SpotifyWebAPI
import Combine


class SpotifyPlaylistsRepository {
    
    private var cancellables = Set<AnyCancellable>()
    private var spotify: Spotify

    init(spotify: Spotify) {
        self.spotify = spotify
    }

    func createPlaylist(playlistDetails: PlaylistDetails, completion: @escaping (Result<Playlist<PlaylistItems>, Error>) -> Void) {
        guard let userId = spotify.currentUser?.id else { return }
        
        spotify.api.createPlaylist(for: userId, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { receiveCompletion in
                    if case .failure(let error) = receiveCompletion {
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    completion(.success(response))
                }
            )
            .store(in: &cancellables) // Store the subscription
    }

    func addToPlaylist(playlistURI: String, uris: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        spotify.api.addToPlaylist(playlistURI, uris: uris)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { receiveCompletion in
                    if case .failure(let error) = receiveCompletion {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables) // Store the subscription
    }
    
    func retrievePlaylists(idsToLoad: [String], completion: @escaping (Result<[Playlist<PlaylistItemsReference>], Error>) -> Void) {
        spotify.api.currentUserPlaylists(limit: 50)
            .extendPages(spotify.api)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completionResult in
                    switch completionResult {
                    case .finished:
                        break
                    case .failure(let error):
                        completion(.failure(error))
                    }
                },
                receiveValue: { playlistsPage in
                    let playlists = playlistsPage.items.filter { idsToLoad.contains($0.id) }
                    completion(.success(playlists))
                }
            )
            .store(in: &spotify.cancellables)
    }
    
    func deletePlaylist(withId Id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        spotify.api.unfollowPlaylistForCurrentUser(playlistURI(URI: Id))
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completionResult in
                    switch completionResult {
                    case .finished:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &spotify.cancellables)
    }
}
