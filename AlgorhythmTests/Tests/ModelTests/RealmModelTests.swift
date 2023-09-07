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
        // Invalidate the in-memory Realm
        realm.invalidate()
        
        super.tearDown()
    }
    
    func testAddingPlaylistOption() {
        let mockList = MockPlaylistOptionsList()
        let newOption = PlaylistOption(genre: "Rock", value: true)

        mockList.playlistOptions.add(newOption)

        XCTAssertEqual(mockList.playlistOptions.count, 1)
        XCTAssertEqual(mockList.playlistOptions.first()?.genre, "Rock")
        XCTAssertEqual(mockList.playlistOptions.first()?.value, true)
    }
    
    func testRemoveAllPlaylistOptions() {
        let mockList = MockPlaylistOptionsList()

        // Add multiple options to the list
        let newOption1 = PlaylistOption(genre: "Rock", value: true)
        let newOption2 = PlaylistOption(genre: "Pop", value: false)

        mockList.playlistOptions.add(newOption1)
        mockList.playlistOptions.add(newOption2)

        // Verify that items have been added
        XCTAssertEqual(mockList.playlistOptions.count, 2)

        // Perform the action to remove all items
        mockList.playlistOptions.removeAll()

        // Verify that all items have been removed
        XCTAssertEqual(mockList.playlistOptions.count, 0)
    }

}
