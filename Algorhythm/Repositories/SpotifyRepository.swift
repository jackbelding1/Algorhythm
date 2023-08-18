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


class SpotifyRepository {
    
    private var spotify: Spotify
    private var cancellables = Set<AnyCancellable>()

    init(spotify: Spotify) {
        self.spotify = spotify
    }

    // Shared properties and methods (if any) can be defined here
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
            .store(in: &cancellables) // Store the subscription
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
            .store(in: &cancellables) // Add this subscription to the collection
    }
    
    func getArtistTopTracks(artistId: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        spotify.api.artistTopTracks(artistURI(URI: artistId), country: "US")
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completionResult in
                    if case .failure(let error) = completionResult {
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    completion(.success(response))
                })
                .store(in: &cancellables) // Store the subscription
        }

    func findMoodGenreTrack(
        mood selectedMood: String, genre selectedGenre: String,
        tracks artistTracks: Node<String?>?, parentNode node: Node<String>?) {

        guard let head = artistTracks, let trackID = head.value else {
//            artistRetryListener.raise(data: node?.next)
            return
        }
        
        Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: trackID)) { [weak self] result in
            switch result {
            case .success(let graphQLResult):
                if let analyzedTrack = graphQLResult.data?.spotifyTrack {
//                    self.handleAnalyzedTrack(analyzedTrack, selectedMood: selectedMood, selectedGenre: selectedGenre, head: head)
                }
            case .failure(_):
                print("error")
            }
        }
    }

//    private func handleAnalyzedTrack(_ analyzedTrack: GraphQLResultHandler<Query.Data>? = nil,
//                                      selectedMood: String,
//                                      selectedGenre: String,
//                                      head: Node<String?>) {
//
//        if analyzedTrack.resultMap["__typename"] as? String == "SpotifyTrackError" {
//            findMoodGenreTrack(mood: selectedMood, genre: selectedGenre, tracks: head.next, parentNode: head)
//            return
//        }
//
//        DispatchQueue.main.async {
//            spotifyAnalysisViewModel.analyzedSongs.append(SpotifyAnalysisModel.init(analyzedSpotifyTrack: analyzedTrack))
//        }
//
//        if spotifyAnalysisViewModel.filterForWriting(mood: selectedMood, genre: selectedGenre, analyzedTracks: spotifyAnalysisViewModel.analyzedSongs) == true {
//            recommendationListener.raise(data: { print("generate recommendations") }())
//        } else {
//            findMoodGenreTrack(mood: selectedMood, genre: selectedGenre, tracks: head.next, parentNode: head)
//        }
//    }
}

// MARK: - SpotifyPlaylistsRepository
extension SpotifyRepository {

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
