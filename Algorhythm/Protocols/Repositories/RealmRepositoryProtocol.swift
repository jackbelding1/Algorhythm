//
//  RealmRepositoryProtocol.swift
//  Algorhythm
//
//  Created by Jack Belding on 9/4/23.
//

import Foundation
import RealmSwift

protocol RealmRepositoryProtocol {
    // Playlist Options Management
    func savePlaylistOptions(_ preferences: [String: Bool])
    func loadPlaylistOptions() -> List<PlaylistOption>?
    func restorePlaylistOptionDefaults()
    
    // Mood and Genre Management
    func readTrackIds(withMood mood: String, withGenre genre: String) -> [String]
    func writeTrackIds(forGenre genre: String, forMood mood: String, ids: [String])
    func writePlaylist(withId id: String)
    func readCreatedPlaylists() -> [String]
    func deletePlaylist(withId id: String)
}
