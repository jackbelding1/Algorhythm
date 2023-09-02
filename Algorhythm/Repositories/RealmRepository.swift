import Foundation
import RealmSwift

class RealmRepository {
    let realm = try! Realm()
    // MARK: - Variables
    
    // MARK: - Initializer
    init() {
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }

}

// Playlist Options Management
extension RealmRepository {
    func savePlaylistOptions(_ preferences: [String: Bool]) {
        let existingOptions = realm.objects(PlaylistOptionsList.self)
        
        let newOptions = preferences.map { PlaylistOption(genre: $0.key, value: $0.value) }
        
        do {
            try realm.write {
                if var currentOptions = existingOptions.first?.playlistOptions {
                    currentOptions.removeAll()
                    for newOption in newOptions {
                        currentOptions.add(newOption)
                    }
                } else {
                    let newCollection = PlaylistOptionsList()
                    for newOption in newOptions {
                        newCollection.playlistOptions.add(newOption)
                    }
                    realm.add(newCollection)
                }
            }
        } catch let error {
            print("Error during Realm write: \(error)")
        }
    }
    
    func loadPlaylistOptions() -> List<PlaylistOption>? {
        return realm.objects(PlaylistOptionsList.self).first?.playlistOptions as? List<PlaylistOption>
    }
    
    func restorePlaylistOptionDefaults() {
        let objectsToDelete = realm.objects(PlaylistOptionsList.self)
        try! realm.write {
            realm.delete(objectsToDelete)
        }
    }
}

// Mood and Genre Management
extension RealmRepository {
    func readTrackIds(withMood mood:String, withGenre genre:String) -> [String] {
        // Filter GenreMoodMapping objects by genre
        let filteredByGenre = realm.objects(GenreMoodMapping.self).filter("genre == %@", genre)
        
        // Initialize an empty array to hold all track IDs
        var allTrackIds: [String] = []
        
        // Loop through each GenreMoodMapping object
        for genreMoodMapping in filteredByGenre {
            // Filter MoodTrackMapping objects by mood
            let filteredMoods = genreMoodMapping.moods.filter("mood == %@", mood)
            
            // Loop through each MoodTrackMapping object and collect track IDs
            for moodTrackMapping in filteredMoods {
                allTrackIds.append(moodTrackMapping.trackID)
            }
        }
        
        return allTrackIds
    }

    
    func writeTrackIds(forGenre genre: String,forMood mood: String, ids: [String]) {
        try! realm.write {
            let genreResults = realm.objects(GenreMoodMapping.self).filter("genre == %@", genre)

            if let existingGenre = genreResults.first {
                for id in ids {
                    let newMoodTrackMapping = MoodTrackMapping(mood: mood, trackID: id) // Assuming MoodTrackMapping has a constructor for individual ids
                    existingGenre.moods.append(newMoodTrackMapping)
                }
            } else {
                let newGenre = GenreMoodMapping()
                newGenre.genre = genre
                // Create and append new MoodTrackMapping objects for the new mood
                for id in ids {
                    let newMoodTrackMapping = MoodTrackMapping(mood: mood, trackID: id)
                    newGenre.moods.append(newMoodTrackMapping)
                }
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
