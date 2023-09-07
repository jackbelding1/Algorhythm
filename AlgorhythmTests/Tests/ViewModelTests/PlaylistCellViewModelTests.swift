import XCTest
@testable import Algorhythm // Replace with your actual module name
import SpotifyWebAPI
import SwiftUI

class PlaylistCellViewModelTests: XCTestCase {
    
    var viewModel: PlaylistCellViewModel!
    var mockSpotifyRepository: MockSpotifyRepository!
    var playlist: Playlist<PlaylistItemsReference>!
    
    override func setUp() {
        super.setUp()
        
        // Initialize mock Spotify repository
        mockSpotifyRepository = MockSpotifyRepository()
        
        // Test JSON data for the playlist
        let jsonData = """
        {
          "name": "Test Playlist",
          "tracks": {
            "href": "https://api.spotify.com/v1/playlists/xyz/tracks",
            "total": 50
          },
          "owner": null,
          "public": true,
          "collaborative": false,
          "description": "A sample playlist",
          "snapshot_id": "snapshot123",
          "external_urls": null,
          "followers": null,
          "href": "https://api.spotify.com/v1/playlists/xyz",
          "id": "xyz",
          "uri": "spotify:playlist:xyz",
          "images": [],
          "type": "playlist"
        }
        """.data(using: .utf8)!
        
        do {
            // Initialize JSON decoder
            let decoder = JSONDecoder()
            
            // Decode Playlist
            playlist = try decoder.decode(Playlist<PlaylistItemsReference>.self, from: jsonData)
            
        } catch {
            print("Failed to decode JSON: \(error)")
            return
        }
        
        // Initialize the view model
        viewModel = PlaylistCellViewModel(spotify: Spotify(), playlist: playlist)
        viewModel.repository = mockSpotifyRepository
    }

    
    func testLoadImage() {
        let expectation = XCTestExpectation(description: "loadImage should complete")
        
        mockSpotifyRepository.expectLoadImage = { receivedPlaylist, completion in
            XCTAssertEqual(receivedPlaylist.id, self.playlist.id)
            completion(nil)
            expectation.fulfill()
        }
        
        viewModel.loadImage { _ in }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetPlaylistName() {
        let playlistName = viewModel.getPlaylistName()
        XCTAssertEqual(playlistName, "Test Playlist")
    }
    
    func testOpenPlaylist() {
        let expectation = XCTestExpectation(description: "openPlaylist should complete")
        
        mockSpotifyRepository.expectOpenPlaylistURL = { receivedPlaylistId in
            XCTAssertEqual(receivedPlaylistId, self.playlist.id)
            expectation.fulfill()
            return nil
        }
        
        _ = viewModel.openPlaylist()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
}
