import RealmSwift
import Foundation

// MARK: - Mood and Track ID Mapping
final class MoodTrackMapping: Object {
    convenience init(mood: String, trackIDs: [String]) {
        self.init()
        self.mood = mood
        self.trackIDs.append(objectsIn: trackIDs)
    }
    
    @objc dynamic var mood: String = ""
    let trackIDs = List<String>()
}

// MARK: - Genre and Mood Mapping
final class GenreMoodMapping: Object {
    let moods = List<MoodTrackMapping>()
    @objc dynamic var genre: String?
}

// MARK: - Individual Playlist
final class IndividualPlaylist: Object {
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    @objc dynamic var id: String = ""
}

// MARK: - Playlist Collection
final class PlaylistCollection: Object {
    let playlists = List<IndividualPlaylist>()
}

// MARK: - Individual Playlist Option
final class PlaylistOption: Object {
    convenience init(genre: String, value: Bool) {
        self.init()
        self.genre = genre
        self.value = value
    }
    
    @objc dynamic var genre: String = ""
    @objc dynamic var value: Bool = false
}

// MARK: - Playlist Options Collection
final class PlaylistOptionsCollection: Object {
    let playlistOptions = List<PlaylistOption>()
}
