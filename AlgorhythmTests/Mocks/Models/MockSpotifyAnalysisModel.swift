//
//  MockSpotifyAnalysisModel.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 9/6/23.
//

import Foundation
@testable import Algorhythm

class MockSpotifyAnalysisModel: SpotifyAnalysisModelProtocol {
    let mockTrack: MockSpotifyTrack
    
    var id: String {
        mockTrack.id
    }
    
    var genreTags: [AudioAnalysisV6GenreTags]? {
        mockTrack.audioAnalysisV6.result.genreTags.compactMap { AudioAnalysisV6GenreTags(rawValue: $0) }
    }
    
    var moodTags: [AudioAnalysisV6MoodTags]? {
        mockTrack.audioAnalysisV6.result.moodTags.compactMap { AudioAnalysisV6MoodTags(rawValue: $0) }
    }
    
    init(mockTrack: MockSpotifyTrack) {
        self.mockTrack = mockTrack
    }
}
