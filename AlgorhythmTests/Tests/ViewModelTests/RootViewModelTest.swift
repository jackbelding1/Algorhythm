//
//  RootViewModelTests.swift
//  AlgorhythmTests
//
//  Created by YourName on 9/2/23.
//

import XCTest
import Combine
import SpotifyWebAPI
@testable import Algorhythm

class RootViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    var mockSpotify: Spotify!
    var viewModel: RootViewModel!
    
    override func setUp() {
        super.setUp()
        mockSpotify = Spotify()
        viewModel = RootViewModel(spotify: mockSpotify)
    }
    
    override func tearDown() {
        cancellables.removeAll()
        viewModel = nil
        mockSpotify = nil
        super.tearDown()
    }
    
    func testHandleAuthRedirectURL() {
        // Given
        let url = URL(string: "algorhythm-app://login-callback")!
        let mockSpotifyRepository = MockSpotifyRepository()
        viewModel.spotifyRepository = mockSpotifyRepository
        
        let expectation = XCTestExpectation(description: "handleAuthRedirectURL should complete")
        
        
        mockSpotifyRepository.expectHandleAuthRedirectURL = { receivedURL in
            XCTAssertEqual(receivedURL, url)
            expectation.fulfill()
        }
        
        // When
        viewModel.handleAuthRedirectURL(url)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    
    func testAlertIsNotNilWhenAuthFails() {
        // Given
        let jsonData = """
        {
            "error": "access_denied",
            "state": "some_state"
        }
        """.data(using: .utf8)!
        
        do {
            let decoder = JSONDecoder()
            let errorInstance = try decoder.decode(SpotifyAuthorizationError.self, from: jsonData)
            
            // When
            if errorInstance.accessWasDenied {
                viewModel.handleAuthCompletion(completion: .failure(errorInstance))
                
                // Then
                XCTAssertNotNil(viewModel.alert)
            } else {
                XCTFail("The error instance does not have 'accessWasDenied' set to true.")
            }
        } catch {
            XCTFail("Failed to decode SpotifyAuthorizationError: \(error)")
        }
    }



    
    func testAlertIsNilWhenAuthSucceeds() {
        // Given & When
        viewModel.handleAuthCompletion(completion: .finished)
        
        // Then
        XCTAssertNil(viewModel.alert)
    }
}
