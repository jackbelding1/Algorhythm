//
//  MockSpotifyRepository.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 9/2/23.
//

import Foundation
import SpotifyWebAPI
import SwiftUI
import Combine
@testable import Algorhythm

// MARK: - MockSpotifyRepository
class MockSpotifyRepository: SpotifyRepositoryProtocol {

    // MARK: - Variables
    var handleAuthRedirectURLCalled: Bool = false
    var receivedURL: URL?
    var completionHandler: ((Subscribers.Completion<Error>) -> Void)?
    var showAlertHandler: ((AlertItem) -> Void)?
    // MARK: - Expectations
    var expectHandleAuthRedirectURL: ((URL) -> Void)?
    var expectOpenPlaylistURL: ((String) -> URL?)?
    var expectLoadImage: ((Playlist<PlaylistItemsReference>, @escaping (Image?) -> Void) -> Void)?
    
    // MARK: - Overridden Methods
    func handleAuthRedirectURL(_ url: URL, completionHandler: @escaping (Subscribers.Completion<Error>) -> Void, showAlert: @escaping (AlertItem) -> Void) {
        handleAuthRedirectURLCalled = true
        receivedURL = url
        self.completionHandler = completionHandler
        self.showAlertHandler = showAlert
        
        // Call the expectation closure if it's set
        expectHandleAuthRedirectURL?(url)
    }
    
    func openPlaylistURL(playlistId: String) -> URL? {
        return expectOpenPlaylistURL?(playlistId)
    }
    
    func getUserTopArtists(timeRange: SpotifyWebAPI.TimeRange, offset: Int, limit: Int, completion: @escaping (Result<[SpotifyWebAPI.Artist], Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func getRecommendations(trackURIs: [String], completion: @escaping (Result<[SpotifyWebAPI.Track], Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func getArtistTopTracks(artistId: String, completion: @escaping (Result<[SpotifyWebAPI.Track], Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func analyzeSpotifyTrack(by id: String, completion: @escaping (Result<Algorhythm.SpotifyTrackQueryQuery.Data.SpotifyTrack, Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func createPlaylist(playlistDetails: SpotifyWebAPI.PlaylistDetails, completion: @escaping (Result<SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItems>, Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func addToPlaylist(playlistURI: String, uris: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func retrievePlaylists(idsToLoad: [String], completion: @escaping (Result<[SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItemsReference>], Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func deletePlaylist(withId Id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fatalError("Not yet implemented")
    }
    
    func loadImage(forPlaylist playlist: SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItemsReference>, completion: @escaping (Image?) -> Void) {
        expectLoadImage?(playlist, completion)
    }
    
    
}
