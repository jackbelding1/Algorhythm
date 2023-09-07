//
//  NewPlaylistViewModelTests.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 9/4/23.
//

import XCTest
@testable import Algorhythm
import Combine

class NewPlaylistViewModelTests: XCTestCase {
    
    var viewModel: NewPlaylistViewModel!
    var mockRealmRepository: MockRealmRepository!

    override func setUp() {
        super.setUp()
        mockRealmRepository = MockRealmRepository()
        viewModel = NewPlaylistViewModel()
        viewModel.realmRepository = mockRealmRepository  // Assuming you make realmRepository injectable
    }
    
    func testInitOptionPreferences() {
        viewModel.initOptionPreferences()
        XCTAssertFalse(viewModel.genrePreferencesCollection.isEmpty, "Genre preferences should not be empty after initialization.")
    }
    
    func testRestorePreferences() {
        viewModel.restorePreferences()
        XCTAssertEqual(viewModel.genrePreferencesCollection, viewModel.initialPreferenceState, "Restored preferences should match the initial state.")
    }
    
    func testHandleTapUpdate() {
        // Test when savePreferences is true
        viewModel.savePreferences = true
        viewModel.handleTapUpdate()
        XCTAssertTrue(mockRealmRepository.savePlaylistOptionsCalled, "savePlaylistOptions should be called when savePreferences is true")

        // Reset mock state
        mockRealmRepository.savePlaylistOptionsCalled = false

        // Test when savePreferences is false
        viewModel.savePreferences = false
        viewModel.handleTapUpdate()
        XCTAssertFalse(mockRealmRepository.savePlaylistOptionsCalled, "savePlaylistOptions should not be called when savePreferences is false")
    }
    
    func testUpdateSavePreferences() {
        let initialSavePreferences = viewModel.savePreferences
        viewModel.updateSavePreferences(isMarked: !initialSavePreferences)
        XCTAssertEqual(viewModel.savePreferences, !initialSavePreferences, "Save preferences should be toggled.")
    }

    
    func testClearGenreSelections() {
        viewModel.clearGenreSelections()
        for preference in viewModel.genrePreferencesCollection {
            XCTAssertFalse(preference.value, "All genre selections should be cleared.")
        }
    }
    
    func testMoodOptionTapped() {
        let mood = "Happy"
        viewModel.moodOptionTapped(mood: mood)
        XCTAssertEqual(viewModel.selectedMood, mood, "Selected mood should be set.")
    }
        
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
}
