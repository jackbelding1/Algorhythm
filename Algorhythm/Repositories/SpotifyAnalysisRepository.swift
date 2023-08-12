//
//  SpotifyAnalysisRepository.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/9/23.
//

import Foundation
import Apollo
import Combine
import SpotifyWebAPI

class SpotifyAnalysisRepository {
    
    private var spotify: Spotify
    private var cancellables = Set<AnyCancellable>()
    
    
    typealias RecommendationListener = Event<Void>
    typealias ArtistRetryListener = Event<Node<String>?>
    
    private var recommendationListener: RecommendationListener = RecommendationListener()
    private var artistRetryListener: ArtistRetryListener = ArtistRetryListener()
    
    
    // the playlist creating result
    enum PlaylistState {
        case inProgress
        case waitingRequest
        case success
        case failure
    }
    
    init(spotify: Spotify) {
        self.spotify = spotify
//        recommendationListener.addHandler(handler: { [self] in
//            getRecommendations(trackURIs: spotifyAnalysisViewModel.seedIds.map {"spotify:track:\($0)"}
//            )})
//        artistRetryListener.addHandler { [self] data in networkRetryHandler(Ids: data)}
    }
    
    // Your networking functions go here
    // ...
    
    // Example:
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
    
    func findMoodGenreTrack(mood selectedMood: String,
                            genre selectedGenre: String, tracks artistTracks: Node<String?>?, parentNode node: Node<String>?) {

        guard let head = artistTracks, let trackID = head.value else {
            artistRetryListener.raise(data: node?.next)
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
    
    // Add other methods similar to the above
    // ...
    

    
//    func networkRetryHandler(Ids:Node<String>?){
//        if let node = Ids {
//            getArtistTopTracks(withIds: node)
//        }
//        else {
//            print("no seeds matching mood found! try again!")
//            getTopArtistRetry()
//        }
//    }
}

