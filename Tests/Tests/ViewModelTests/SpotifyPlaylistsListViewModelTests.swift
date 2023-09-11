//
//  SpotifyPlaylistsListViewModelTests.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 9/2/23.
//

import XCTest
import SpotifyWebAPI
@testable import Algorhythm // Replace with your actual module name

class SpotifyPlaylistsListViewModelTests: XCTestCase {
    
    var viewModel: SpotifyPlaylistsListViewModel!
    var mockSpotifyRepository: MockSpotifyRepository = MockSpotifyRepository()
    var mockRealmRepository: MockRealmRepository = MockRealmRepository()
    var mockPlaylist: Playlist<PlaylistItemsReference>!
    
    override func setUp() {
        super.setUp()
        
        // Initialize mock Playlist from JSON
            let jsonData = """
            {
                "id": "testID",
                "name": "Test Playlist",
                "tracks": {
                    "href": null,
                    "total": 0
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
                mockPlaylist = try decoder.decode(Playlist<PlaylistItemsReference>.self, from: jsonData)
            } catch {
                print("Failed to decode Playlist: \(error)")
            }
        
        // Initialize the view model
        viewModel = SpotifyPlaylistsListViewModel(spotify: Spotify())
        viewModel.spotifyRepository = mockSpotifyRepository
        viewModel.realmRepository = mockRealmRepository
    }
    
    func testDeletePlaylist() {
        // Given
        viewModel.playlists = [mockPlaylist]
        
        // Expectations
        mockSpotifyRepository.expectDeletePlaylist = { receivedPlaylistId, completion in
            XCTAssertEqual(receivedPlaylistId, self.mockPlaylist.id)
            completion(.success(()))  // You can also simulate failure here if needed
        }

        mockRealmRepository.expectDeletePlaylist = { receivedPlaylistId in
            XCTAssertEqual(receivedPlaylistId, self.mockPlaylist.id)
        }
        
        // When
        viewModel.playlists.remove(at: 0)
        
        // Then
        XCTAssertTrue(viewModel.playlists.isEmpty)
    }
    
    func testRetrievePlaylists() {
        // Given
        let expectedIds = ["id1", "id2"]
        mockRealmRepository.expectReadCreatedPlaylists = { return expectedIds }
        
        var retrievedIds: [String]?
        mockSpotifyRepository.expectRetrievePlaylists = { ids, completion in
            retrievedIds = ids
            completion(.success([])) // You can also test failure cases
        }
        
        // When
        viewModel.retrievePlaylists()
        
        // Then
        XCTAssertTrue(viewModel.playlists.isEmpty)
        XCTAssertEqual(retrievedIds, expectedIds)
        XCTAssertEqual(viewModel.isLoadingPlaylists, false)

    }
    
}
