import RealmSwift
import Foundation

// MARK: - Mood and Track ID Mapping
final class MoodTrackMapping: Object {
    convenience init(mood: String, trackID: String) {
        self.init()
        self.mood = mood
        self.trackID = trackID
    }
    
    @objc dynamic var mood: String = ""
    @objc dynamic var trackID: String = ""
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
// Realm object
final class PlaylistOptionsList: Object, PlaylistOptionsListProtocol {
    
    var playlistOptions: AnyPlaylistOptionList { get {
        return playlistOptionsRealm } set {
            
        }
    }
    private var playlistOptionsRealm: List<PlaylistOption> = List<PlaylistOption>()
    // TODO: REMOVE
    @objc var test: Int = 1
}
