//
//  SpotifyAnalysisRepository.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/9/23.
//

import Foundation
import Combine
import SpotifyWebAPI

class SpotifyAnalysisRepository {
    
    private var spotify: Spotify
    private var cancellables = Set<AnyCancellable>()
    private var spotifyAnalysisViewModel: SpotifyAnalysisListViewModel
    
    
    // the playlist creating result
    enum PlaylistState {
        case inProgress
        case waitingRequest
        case success
        case failure
    }
    
    init(spotify: Spotify, spotifyAnalysisViewModel: SpotifyAnalysisListViewModel) {
        self.spotify = spotify
        self.spotifyAnalysisViewModel = spotifyAnalysisViewModel
    }
    
    // Your networking functions go here
    // ...
    
    // Example:
    func getRecommendations(trackURIs: [String], completion: @escaping (Result<[Track], Error>) -> Void) {
        self.spotify.api
            .recommendations(TrackAttributes(seedTracks: trackURIs), limit: 30)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: getRecommendationsCompletion(_:),
                receiveValue: { response in
                    self.spotifyAnalysisViewModel.recommendedTracks = response.tracks
                })
            .store(in: &cancellables) // Add this subscription to the collection
    }
    
    // Add other methods similar to the above
    // ...
    
    func handleCompletion(
        _ completion: Subscribers.Completion<Error>,
        title: String,
        updatePlaylistState: Bool = false,
        updateLoadingPage: Bool = false
    ) {
        if case .failure(let error) = completion {
            if updatePlaylistState {
                spotifyAnalysisViewModel.playlistCreationState = .failure
            }
            print("\(title): \(error)")
            spotifyAnalysisViewModel.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
            if updateLoadingPage {
                spotifyAnalysisViewModel.isLoadingPage = false
            }
        }
    }
    
    func createPlaylistCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't create playlist", updatePlaylistState: true)
    }
    
    func addTracksCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't add items", updatePlaylistState: true)
    }
    
    func getRecommendationsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't retrieve recommendations")
    }
    
    func getTopArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't retrieve user top artists", updateLoadingPage: true)
    }
    
    func getArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't retrieve artists", updateLoadingPage: true)
    }
    
    func getArtistTopTracksCompletion(
        _ completion: Subscribers.Completion<Error>
    ){
        handleCompletion(completion, title: "Couldn't retrieve artist top tracks", updateLoadingPage: true)
    }
    
}

