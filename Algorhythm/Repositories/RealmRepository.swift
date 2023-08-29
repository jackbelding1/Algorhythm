import Foundation
import RealmSwift

class RealmRepository {
    let realm = try! Realm()
    
    init() {
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
}

// Playlist Options Management
extension RealmRepository {
    func savePlaylistOptions(_ preferences: [String: Bool]) {
        let existingOptions = realm.objects(PlaylistOptionsCollection.self)
        
        let newOptions = preferences.map { PlaylistOption(genre: $0.key, value: $0.value) }
        
        try! realm.write {
            if let currentOptions = existingOptions.first?.playlistOptions {
                currentOptions.removeAll()
                currentOptions.append(objectsIn: newOptions)
            } else {
                let newCollection = PlaylistOptionsCollection()
                newCollection.playlistOptions.append(objectsIn: newOptions)
                realm.add(newCollection)
            }
        }
    }
    
    func loadPlaylistOptions() -> List<PlaylistOption>? {
        return realm.objects(PlaylistOptionsCollection.self).first?.playlistOptions
    }
    
    func restorePlaylistOptionDefaults() {
        let objectsToDelete = realm.objects(PlaylistOptionsCollection.self)
        try! realm.write {
            realm.delete(objectsToDelete)
        }
    }
}

// Mood and Genre Management
extension RealmRepository {
    func readTrackIds(forGenre genre: String,forMood mood: String) -> [String] {
        let results = realm.objects(GenreMoodMapping.self).filter { $0.genre == genre }
        return results.first?.moods.first(where: { $0.mood == mood })?.trackIDs.toArray() ?? []
    }
    
    func writeTrackIds(forGenre genre: String,forMood mood: String, ids: [String]) {
        try! realm.write {
            let genreResults = realm.objects(GenreMoodMapping.self).filter("genre == %@", genre)

            if let existingGenre = genreResults.first {
                let moodResults = existingGenre.moods.filter("mood == %@", mood)
                
                if let existingMood = moodResults.first {
                    existingMood.trackIDs.removeAll()
                    existingMood.trackIDs.append(objectsIn: ids)
                } else {
                    let newMood = MoodTrackMapping(mood: mood, trackIDs: ids)
                    existingGenre.moods.append(newMood)
                }
            } else {
                let newGenre = GenreMoodMapping()
                newGenre.genre = genre
                let newMood = MoodTrackMapping(mood: mood, trackIDs: ids)
                newGenre.moods.append(newMood)
                realm.add(newGenre)
            }
        }
    }
    
    func writePlaylist(withId id: String) {
        let playlistObject = IndividualPlaylist(id: id)
        try! realm.write {
            realm.add(playlistObject)
        }
    }
    
    // Function to read IDs of created individual playlists
    func readCreatedPlaylists() -> [String] {
        let results = realm.objects(IndividualPlaylist.self)
        var playlistIds: [String] = []
        
        for playlist in results {
            playlistIds.append(playlist.id)
        }
        
        return playlistIds
    }

    
    func deletePlaylist(withId id: String) {
        if let playlistToDelete = realm.objects(IndividualPlaylist.self).filter("id == %@", id).first {
            try! realm.write {
                realm.delete(playlistToDelete)
            }
        }
    }
}

extension List {
    func toArray() -> [Element] {
        return compactMap {
            $0
        }
    }
}
