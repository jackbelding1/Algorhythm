//  SpotifyAnalysisModelTests.swift
//  AlgorhythmTests
//
//  Created by Your Name on 8/30/23.
//
import XCTest
@testable import Algorhythm

class SpotifyAnalysisModelTests: XCTestCase {
    
    var spotifyAnalysisModel: SpotifyAnalysisModel!
    var mockSpotifyTrack: MockSpotifyTrack!
    
    override func setUp() {
        super.setUp()
        
        // Initialize MockSpotifyTrack and SpotifyAnalysisModel
        setupMockSpotifyTrack()
        setupSpotifyAnalysisModel()
    }
    
    override func tearDown() {
        spotifyAnalysisModel = nil
        super.tearDown()
    }
    
    func setupMockSpotifyTrack() {
        let result = MockSpotifyTrack.AudioAnalysisV6Finished.Result(genreTags: ["Pop", "Rock"], moodTags: ["Happy", "Energetic"])
        let audioAnalysisV6 = MockSpotifyTrack.AudioAnalysisV6Finished(result: result)
        mockSpotifyTrack = MockSpotifyTrack(id: "12345", audioAnalysisV6: audioAnalysisV6)
    }
    
    func setupSpotifyAnalysisModel() {
        let analyzedSpotifyTrack = convertMockToReal(mockSpotifyTrack)
        spotifyAnalysisModel = SpotifyAnalysisModel(analyzedSpotifyTrack: analyzedSpotifyTrack)
    }
    
    func testInitialization() {
        XCTAssertNotNil(spotifyAnalysisModel)
    }
    
    func testID() {
        XCTAssertEqual(spotifyAnalysisModel.id, mockSpotifyTrack.id)
    }
    
    func testGenreTags() {
        let (expected, actual) = getTags(for: "genreTags")
        XCTAssertEqual(expected, actual, "Failed to match genreTags")
    }

    func testMoodTags() {
        let (expected, actual) = getTags(for: "moodTags")
        XCTAssertEqual(expected, actual, "Failed to match moodTags")
    }
    
    func getTags(for key: String) -> ([String]?, [String]?) {
        if let tagsAny = spotifyAnalysisModel.analyzedSpotifyTrack.resultMap["audioAnalysisV6"] as? [String: Any],
           let resultAny = tagsAny["result"] as? [String: Any],
           let resultTagsAny = resultAny["result"] as? [String: Any],
           let tags = resultTagsAny[key] as? [AudioAnalysisV6GenreTags] {
            
            let expectedTags = (key == "genreTags") ? mockSpotifyTrack.audioAnalysisV6.result.genreTags : mockSpotifyTrack.audioAnalysisV6.result.moodTags
            let actualTags = tags.map { $0.rawValue }
            
            return (expectedTags, actualTags)
        }
        
        return (nil, nil)
    }
    
    func convertMockToReal(_ mock: MockSpotifyTrack) -> SpotifyTrackQueryQuery.Data.SpotifyTrack {
        // Create the AudioAnalysisV6Finished.Result object
        let realResult = SpotifyTrackQueryQuery.Data.SpotifyTrack.AsSpotifyTrack.AudioAnalysisV6.AsAudioAnalysisV6Finished.Result(
            genreTags: mock.audioAnalysisV6.result.genreTags.map { AudioAnalysisV6GenreTags(rawValue: $0)! },
            moodTags: mock.audioAnalysisV6.result.moodTags.map { AudioAnalysisV6MoodTags(rawValue: $0)! }
        )
        
        // Create the AudioAnalysisV6Finished object
        let realAudioAnalysisV6Finished = SpotifyTrackQueryQuery.Data.SpotifyTrack.AsSpotifyTrack.AudioAnalysisV6.AsAudioAnalysisV6Finished(result: realResult)
        
        // Create the AudioAnalysisV6 object
        let realAudioAnalysisV6 = SpotifyTrackQueryQuery.Data.SpotifyTrack.AsSpotifyTrack.AudioAnalysisV6(unsafeResultMap: ["__typename": "AudioAnalysisV6Finished", "result": realAudioAnalysisV6Finished.resultMap])
        
        // Create the real SpotifyTrack object
        let realSpotifyTrack = SpotifyTrackQueryQuery.Data.SpotifyTrack.makeSpotifyTrack(id: mock.id, audioAnalysisV6: realAudioAnalysisV6)
        
        return realSpotifyTrack
    }
}
