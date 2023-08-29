//
//  SpotifyRepository.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/17/23.
//

import Foundation
import Apollo
import Combine
import SpotifyWebAPI
import SwiftUI // TODO: REPLACE WITH DEPENDENCY INJECTION

// MARK: - Variables
struct ArtistURI: SpotifyURIConvertible {
    public let uri: String
    
    init(artistUri: String) {
        self.uri = "spotify:artist:\(artistUri)"
    }
}

class SpotifyRepository {
    // MARK: - Variables
    private var spotify: Spotify
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(spotify: Spotify) {
        self.spotify = spotify
    }

    // MARK: - Shared properties
    func openPlaylistURL(playlistId: String) -> URL? {
        let spotifyUrl = URL(string: "spotify://playlist/\(playlistId)")!
        if UIApplication.shared.canOpenURL(spotifyUrl) {
            return spotifyUrl
        } else {
            return URL(string: "https://itunes.apple.com/us/app/apple-store/id324684580")
        }
    }
}

// MARK: - SpotifyAnalysisRepository
extension SpotifyRepository {
    
    func getUserTopArtists(timeRange: TimeRange, offset: Int, limit: Int, completion: @escaping (Result<[Artist], Error>) -> Void) {
        spotify.api
            .currentUserTopArtists(timeRange, offset: offset, limit: limit)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completionResult in
                    if case .failure(let error) = completionResult {
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    completion(.success(response.items))
                })
            .store(in: &cancellables)
    }
    
    
    func getRecommendations(trackURIs: [String], completion: @escaping (Result<[Track], Error>) -> Void) {
        self.spotify.api
            .recommendations(TrackAttributes(seedTracks: trackURIs), limit: 30)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { receiveCompletion in
                    if case .failure(let error) = receiveCompletion {
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    completion(.success(response.tracks))
                })
            .store(in: &cancellables)
    }

    func getArtistTopTracks(artistId: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        spotify.api.artistTopTracks(ArtistURI(artistUri: artistId), country: "US")
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    completion(.failure(error))
                }
            },
                  receiveValue: { response in
                completion(.success(response))
            })
            .store(in: &cancellables)
    }
}

// MARK: - SpotifyPlaylistsRepository
extension SpotifyRepository {
    
    func analyzeSpotifyTrack(by id: String, completion: @escaping (Result<SpotifyTrackQueryQuery.Data.SpotifyTrack, Error>) -> Void) {
            Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let analyzedTrack = graphQLResult.data?.spotifyTrack {
                        completion(.success(analyzedTrack))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: ["message": "Analyzed track data is nil"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
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
            .store(in: &cancellables)
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
            .store(in: &cancellables)
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

// MARK: - SpotifyPlaylistCell
extension SpotifyRepository {
    func loadImage(forPlaylist playlist: Playlist<PlaylistItemsReference>,
                   completion: @escaping (Image?) -> Void) {
        guard let spotifyImage = playlist.images.largest else {
            return 
        }
        
        spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { uiImage in
                    completion(uiImage)
                }
            )
            .store(in: &cancellables)
    }
}
// MARK: - RootViewModel
extension SpotifyRepository {
    func handleAuthRedirectURL(_ url: URL, completionHandler: @escaping (Subscribers.Completion<Error>) -> Void, showAlert: @escaping (AlertItem) -> Void) {
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            showAlert(AlertItem(
                title: "Cannot Handle Redirect",
                message: "Unexpected URL"
            ))
            return
        }
        
        print("received redirect from Spotify: '\(url)'")
        spotify.isRetrievingTokens = true
        
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.spotify.isRetrievingTokens = false
            completionHandler(completion) // Calling the completion handler
        })
        .store(in: &cancellables)
        
        self.spotify.authorizationState = String.randomURLSafe(length: 128)
    }
}
