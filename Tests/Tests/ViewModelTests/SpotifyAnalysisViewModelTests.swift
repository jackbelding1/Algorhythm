//
//  SpotifyAnalysisViewModelTests.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 9/5/23.
//

import XCTest
import SpotifyWebAPI
@testable import Algorhythm

class SpotifyAnalysisViewModelTests: XCTestCase {
    
    var viewModel: SpotifyAnalysisViewModel!
    var mockSpotifyRepository: MockSpotifyRepository!
    var mockPlaylist: Playlist<PlaylistItems>!
    let mood = "Energetic"
    let genre = "edm"
    
    override func setUp() {
        super.setUp()
        
        // Initialize mock Playlist from JSON (same as your original code)
        let jsonData = """
        {
            "id": "testID",
            "name": "Test Playlist",
            "tracks": {
                "items": [],
                "href": "http://example.com/tracks",
                "total": 0,
                "limit": 50,
                "offset": 0
            },
            "owner": null,
            "public": true,
            "collaborative": false,
            "description": null,
            "snapshot_id": "snapshot123",
            "external_urls": null,
            "followers": null,
            "href": "http://example.com",
            "uri": "spotify:playlist:testID",
            "images": [],
            "type": "playlist"
        }
        """.data(using: .utf8)!
        
        do {
            let decoder = JSONDecoder()
            mockPlaylist = try decoder.decode(Playlist<PlaylistItems>.self, from: jsonData)
        } catch {
            print("Failed to decode Playlist: \(error)")
        }
        
        mockSpotifyRepository = MockSpotifyRepository()
        
        // Initialize the view model
        viewModel = SpotifyAnalysisViewModel(spotify: Spotify(), withMood: mood, withGenre: genre)
        viewModel.spotifyRepository = mockSpotifyRepository
    }
    
    
    
    func testRecommendedTracksEmpty() {
        XCTAssertTrue(viewModel.recommendedTracksEmpty())
    }
    
    func testGetAnalyzedSongsCount() {
        XCTAssertEqual(viewModel.getAnalyzedSongsCount(), 0)
    }
    
    func testPlaylistCreationState() {
        XCTAssertEqual(viewModel.playlistCreationState, .inProgress)
    }
    
    func testCreatePlaylistCompletionSuccess() {
        // Arrange
        let mockRepository = MockSpotifyRepository()
        let viewModel = SpotifyAnalysisViewModel(spotify: Spotify(), withMood: "Happy", withGenre: "Pop")
        viewModel.spotifyRepository = mockRepository
        mockRepository.shouldCreatePlaylistSucceed = true // Flag to control behavior
        
        // Act
        viewModel.createPlaylist(withPlaylistName: "Test Playlist")
        
        // Assert
        XCTAssertEqual(viewModel.createdPlaylistId, "testID") // Assuming "testID" is the ID of the mock playlist
    }
    
    func testCreatePlaylistCompletionFailure() {
        // Arrange
        let mockRepository = MockSpotifyRepository()
        let viewModel = SpotifyAnalysisViewModel(spotify: Spotify(), withMood: "Happy", withGenre: "Pop")
        viewModel.spotifyRepository = mockRepository
        mockRepository.shouldCreatePlaylistSucceed = false // Flag to control behavior
        
        // Act
        viewModel.createPlaylist(withPlaylistName: "Test Playlist")
        
        // Assert
        XCTAssertEqual(viewModel.createdPlaylistId, "")
        XCTAssertNotNil(viewModel.alert)
    }
    
    func testGenerateRecommendationsWithEmptySeedIds() {
        let mockSpotifyRepository = MockSpotifyRepository()
        let mockRealmRepository = MockRealmRepository()
        let viewModel = SpotifyAnalysisViewModel(spotify: Spotify(), withMood: "Energetic", withGenre: "edm")
        viewModel.realmRepository = mockRealmRepository
        viewModel.spotifyRepository = mockSpotifyRepository
        
        // Call `generateRecommendations`
        viewModel.generateRecommendations()
        
        // Assert that `getRecommendedTracks` was called on the mock repository
        XCTAssertTrue(mockSpotifyRepository.getRecommendedTracksCalled)
        XCTAssertTrue(mockSpotifyRepository.analyzeSpotifyTrackCalled)
        XCTAssertTrue(mockSpotifyRepository.getUserTopArtistsCalled)
        XCTAssertTrue(mockSpotifyRepository.getArtistTopTracksCalled)
    }
    
    func testGenerateRecommendationsWithSeedIds() {
        var mockTracksIds: [String: [String]] = [:]
        mockTracksIds["edm_Energetic"] = ["5JeBHduTGxXxytZFXBcIlB"]
        let mockSpotifyRepository = MockSpotifyRepository()
        let mockRealmRepository = MockRealmRepository()
        mockRealmRepository.mockTrackIds = mockTracksIds
        let viewModel = SpotifyAnalysisViewModel(spotify: Spotify(), withMood: "Energetic", withGenre: "edm")
        viewModel.realmRepository = mockRealmRepository
        viewModel.spotifyRepository = mockSpotifyRepository
        
        // Call `generateRecommendations`
        viewModel.generateRecommendations()
        
        // Assert that `getRecommendedTracks` was called on the mock repository
        XCTAssertTrue(mockSpotifyRepository.getRecommendedTracksCalled)
    }
    
    func testTrackIsSelectedGenre() {
        let viewModel = SpotifyAnalysisViewModel(spotify: Spotify(), withMood: "Happy", withGenre: "rock")
        // Create a mock SpotifyTrack with specific genreTags
        let mockTrack = MockSpotifyTrack(id: "1", audioAnalysisV6: MockSpotifyTrack.AudioAnalysisV6Finished(result: MockSpotifyTrack.AudioAnalysisV6Finished.Result(genreTags: ["rock"], moodTags: [])))
        let mockModel = MockSpotifyAnalysisModel(mockTrack: mockTrack)
        
        // Call `trackIsSelectedGenre` and assert the expected behavior
        let result = viewModel.trackIsSelectedGenre(mockModel)
        XCTAssertTrue(result, "Expected track to be of the selected genre")
    }
    
    func testTrackIsSelectedMood() {
        let viewModel = SpotifyAnalysisViewModel(spotify: Spotify(), withMood: "Happy", withGenre: "rock")
        // Create a mock SpotifyTrack with specific moodTags
        let mockTrack = MockSpotifyTrack(id: "1", audioAnalysisV6: MockSpotifyTrack.AudioAnalysisV6Finished(result: MockSpotifyTrack.AudioAnalysisV6Finished.Result(genreTags: [], moodTags: ["Happy"])))
        let mockModel = MockSpotifyAnalysisModel(mockTrack: mockTrack)
        
        // Call `trackIsSelectedMood` and assert the expected behavior
        let result = viewModel.trackIsSelectedMood(mockModel)
        XCTAssertTrue(result, "Expected track to be of the selected mood")
    }
}
