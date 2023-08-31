// MockSpotifyTrack.swift
import Foundation

struct MockSpotifyTrack {
    var id: String
    var audioAnalysisV6: AudioAnalysisV6Finished
    
    struct AudioAnalysisV6Finished {
        var result: Result
        
        struct Result {
            var genreTags: [String]
            var moodTags: [String]
        }
    }
}
