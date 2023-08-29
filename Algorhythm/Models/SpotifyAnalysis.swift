//
//  SpotifyAnalysis.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/9/23.
//

import Foundation

class SpotifyAnalysisModel {
    
    // MARK: - Properties
    
    let analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack
    
    var id: String {
        analyzedSpotifyTrack.asSpotifyTrack!.id
    }
    
    // MARK: - Initializer
    
    init(analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack) {
        self.analyzedSpotifyTrack = analyzedSpotifyTrack
    }
    
    // MARK: - Computed Properties
    
    // the genres associated with the track
    var genreTags:[AudioAnalysisV6GenreTags]? {
        analyzedSpotifyTrack.asSpotifyTrack?.audioAnalysisV6.asAudioAnalysisV6Finished?.result.genreTags
    }
    
    var moodTags:[AudioAnalysisV6MoodTags]? {
        analyzedSpotifyTrack.asSpotifyTrack?.audioAnalysisV6.asAudioAnalysisV6Finished?.result.moodTags
    }
    
    // MARK: - Enumerations
    
    enum Moods: CaseIterable {
        case Aggressive
        case Happy
        case Calm
        case Romantic
        case Dark
        case Sad
        case Energetic
        case Sexy
    }
}
