//
//  MockRealmRepository.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 9/4/23.
//

import Foundation
import RealmSwift
@testable import Algorhythm

class MockRealmRepository: RealmRepositoryProtocol {
    
    typealias PlaylistOption = Algorhythm.PlaylistOption
    
    var mockPlaylistOptions: [String: Bool] = [
        "edm": false,
        "country": false,
        "rap": false
    ]
    var mockTrackIds: [String: [String]] = [:] // Key is "\(genre)_\(mood)"
    var mockPlaylists: [String] = []
    var savePlaylistOptionsCalled = false
    var expectDeletePlaylist: ((String) -> Void)?
    var expectReadCreatedPlaylists: (() -> [String])?
    
    func savePlaylistOptions(_ preferences: [String: Bool]) {
        savePlaylistOptionsCalled = true
    }
    
    //
    // TODO: update signature to return a [String: Bool] object.
    //
    func loadPlaylistOptions() -> [String: Bool] {
        return mockPlaylistOptions
    }
    
    func restorePlaylistOptionDefaults() {
        mockPlaylistOptions.removeAll()
    }
    
    func readTrackIds(withMood mood: String, withGenre genre: String) -> [String] {
        return mockTrackIds["\(genre)_\(mood)"] ?? []
    }
    
    func writeTrackIds(forGenre genre: String, forMood mood: String, ids: [String]) {
        mockTrackIds["\(genre)_\(mood)"] = ids
    }
    
    func writePlaylist(withId id: String) {
        mockPlaylists.append(id)
    }
    
    func readCreatedPlaylists() -> [String] {
        return expectReadCreatedPlaylists?() ?? []
    }
    
    func deletePlaylist(withId id: String) {
        expectDeletePlaylist?(id)
    }
}
