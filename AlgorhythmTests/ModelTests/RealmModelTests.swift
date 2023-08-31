import XCTest
import RealmSwift

@testable import Algorhythm

class MoodTrackMappingTests: XCTestCase {
    
    var moodTrackMapping: MoodTrackMapping!

    override func setUp() {
        super.setUp()
        moodTrackMapping = MoodTrackMapping(mood: "Happy", trackID: "1")
    }

    override func tearDown() {
        moodTrackMapping = nil
        super.tearDown()
    }

    func testMoodProperty() {
        XCTAssertEqual(moodTrackMapping.mood, "Happy", "Mood should be Happy")
    }

    func testTrackIDProperty() {
        XCTAssertEqual(moodTrackMapping.trackID, "1", "TrackID should be 1")
    }
}

class GenreMoodMappingTests: XCTestCase {
    
    func testGenreMoodMappingInitialization() {
        let genreMoodMapping = GenreMoodMapping()
        genreMoodMapping.genre = "Pop"
        
        XCTAssertEqual(genreMoodMapping.genre, "Pop")
    }
}

class IndividualPlaylistTests: XCTestCase {
    
    func testIndividualPlaylistInitialization() {
        let individualPlaylist = IndividualPlaylist(id: "123")
        
        XCTAssertEqual(individualPlaylist.id, "123")
    }
}

class PlaylistOptionTests: XCTestCase {
    
    func testPlaylistOptionInitialization() {
        let playlistOption = PlaylistOption(genre: "Rock", value: true)
        
        XCTAssertEqual(playlistOption.genre, "Rock")
        XCTAssertEqual(playlistOption.value, true)
    }
}


class PlaylistOptionsCollectionTests: XCTestCase {
    
    var realm: Realm!
    
    override func setUp() {
        super.setUp()
        
        // Initialize Realm for testing
        do {
            realm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: self.name))
        } catch {
            XCTFail("Failed to create in-memory Realm instance: \(error)")
        }
    }
    
    override func tearDown() {
        // Perform additional cleanup, if needed
        
        // Invalidate the in-memory Realm
        realm.invalidate()
        
        super.tearDown()
    }
    
    func testAddingPlaylistOption() {
        let mockList = MockPlaylistOptionsList()
        let newOption = PlaylistOption(genre: "Rock", value: true)

        mockList.playlistOptions.add(newOption)

        // Assuming you add a 'count' method to your AnyPlaylistOptionList protocol
//        XCTAssertEqual(mockList.playlistOptions.count, 1)

        // Assuming you add a 'first' method to your AnyPlaylistOptionList protocol
        XCTAssertEqual(mockList.playlistOptions.first()?.genre, "Rock")
        XCTAssertEqual(mockList.playlistOptions.first()?.value, true)
    }
}
