//
//  MockRealmRepository.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 9/4/23.
//

import Foundation
@testable import Algorhythm
import RealmSwift

class MockRealmRepository: RealmRepositoryProtocol {
    
    func loadPlaylistOptions() -> RealmSwift.List<Algorhythm.PlaylistOption>? {
        fatalError("method not implemented")
    }
    
    var mockPlaylistOptions: [String: Bool] = [:]
    var mockTrackIds: [String: [String]] = [:] // Key is "\(genre)_\(mood)"
    var mockPlaylists: [String] = []

    var expectDeletePlaylist: ((String) -> Void)?
    var expectReadCreatedPlaylists: (() -> [String])?
    
    func savePlaylistOptions(_ preferences: [String: Bool]) {
        mockPlaylistOptions = preferences
    }
    
    func loadPlaylistOptions() -> List<PlaylistOption>? {
        let list = List<PlaylistOption>()
        for (key, value) in mockPlaylistOptions {
            let option = PlaylistOption(genre: key, value: value)
            list.add(option)
        }
        return list
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
