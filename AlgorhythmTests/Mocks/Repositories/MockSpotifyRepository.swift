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
    
    enum MockRepositoryError: Error {
        case decodingFailed
        case customError
    }
    // MARK: - Mock Data
    var mockPlaylist: SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItems>?
    
    // MARK: - Variables
    var handleAuthRedirectURLCalled: Bool = false
    var getRecommendedTracksCalled = false
    var getUserTopArtistsCalled = false
    var getArtistTopTracksCalled = false
    var analyzeSpotifyTrackCalled = false
    
    var receivedURL: URL?
    var completionHandler: ((Subscribers.Completion<Error>) -> Void)?
    var showAlertHandler: ((AlertItem) -> Void)?
    // Use this flag to simulate success or failure
    var shouldSucceed: Bool = true
    var shouldCreatePlaylistSucceed: Bool = true
    // MARK: - Expectations
    var expectHandleAuthRedirectURL: ((URL) -> Void)?
    var expectOpenPlaylistURL: ((String) -> URL?)?
    var expectLoadImage: ((Playlist<PlaylistItemsReference>, @escaping (Image?) -> Void) -> Void)?
    var expectDeletePlaylist: ((String, @escaping (Result<Void, Error>) -> Void) -> Void)?
    var expectRetrievePlaylists: (([String], (Result<[Playlist<PlaylistItemsReference>], Error>) -> Void) -> Void)?
    
    
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
        getUserTopArtistsCalled = true
        getArtistTopTracks(artistId: "someArtistId", completion: {_ in })
    }
    
    func getRecommendations(trackURIs: [String], completion: @escaping (Result<[SpotifyWebAPI.Track], Error>) -> Void) {
        getRecommendedTracksCalled = true
        
    }
    
    func getArtistTopTracks(artistId: String, completion: @escaping (Result<[SpotifyWebAPI.Track], Error>) -> Void) {
        getArtistTopTracksCalled = true
        analyzeSpotifyTrack(by: "someTrackId", completion: {_ in })
    }
    
    func analyzeSpotifyTrack(by id: String, completion: @escaping (Result<Algorhythm.SpotifyTrackQueryQuery.Data.SpotifyTrack, Error>) -> Void) {
        analyzeSpotifyTrackCalled = true
        getRecommendations(trackURIs: ["someTrackURI"], completion: {_ in })
    }
    
    func createPlaylist(playlistDetails: SpotifyWebAPI.PlaylistDetails, completion: @escaping (Result<SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItems>, Error>) -> Void) {
        
        let playlistDetailsDictionary: [String: Any] = [
            "id": "testID",
            "name": playlistDetails.name,
            "tracks": [
                "items": [],
                "href": "http://example.com/tracks",
                "total": 0,
                "limit": 50,
                "offset": 0
            ],
            "owner": NSNull(),
            "public": playlistDetails.isPublic,
            "collaborative": playlistDetails.isCollaborative,
            "description": playlistDetails.description ?? NSNull(),
            "snapshot_id": "snapshot123",
            "external_urls": NSNull(),
            "followers": NSNull(),
            "href": "http://example.com",
            "uri": "spotify:playlist:testID",
            "images": [],
            "type": "playlist"
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: playlistDetailsDictionary, options: [])
            let decoder = JSONDecoder()
            mockPlaylist = try decoder.decode(SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItems>.self, from: jsonData)
            if shouldCreatePlaylistSucceed {
                completion(.success(mockPlaylist!))
            } else {
                completion(.failure(MockRepositoryError.customError))
            }
        } catch {
            print("Failed to decode Playlist: \(error)")
            completion(.failure(MockRepositoryError.decodingFailed))
        }
        NotificationCenter.default.post(name: NSNotification.Name("CreatePlaylistCalled"), object: nil)
    }


    
    func addToPlaylist(playlistURI: String, uris: [String], completion: @escaping (Result<Void, Error>) -> Void) {
    // Simulate some network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            
            DispatchQueue.main.async {
                
                if self.shouldSucceed {
                    // Simulate a successful operation
                    completion(.success(()))
                } else {
                    // Simulate an error
                    let error = NSError(domain: "MockSpotifyRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to add to playlist"])
                    completion(.failure(error))
                }
                
            }
            
        }
    }
    
    func retrievePlaylists(idsToLoad: [String], completion: @escaping (Result<[SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItemsReference>], Error>) -> Void) {
        expectRetrievePlaylists?(idsToLoad, completion)
    }
    
    func deletePlaylist(withId Id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        expectDeletePlaylist?(Id, completion)
    }
    
    func loadImage(forPlaylist playlist: SpotifyWebAPI.Playlist<SpotifyWebAPI.PlaylistItemsReference>, completion: @escaping (Image?) -> Void) {
        expectLoadImage?(playlist, completion)
    }
    
    
}
