// MockSpotifyTrack.swift
import Foundation

class MockSpotifyTrack {
    var id: String
    var audioAnalysisV6: AudioAnalysisV6Finished
    
    init(id: String, audioAnalysisV6: AudioAnalysisV6Finished) {
        self.id = id
        self.audioAnalysisV6 = audioAnalysisV6
    }
    
    class AudioAnalysisV6Finished {
        var result: Result
        
        init(result: Result) {
            self.result = result
        }
        
        class Result {
            var genreTags: [String]
            var moodTags: [String]
            
            init(genreTags: [String], moodTags: [String]) {
                self.genreTags = genreTags
                self.moodTags = moodTags
            }
        }
    }
}
