//
//  SeedCacheManager.swift
//  Algorhythm
//
//  Created by Jack Belding on 11/24/22.
//

import Foundation

final class TracksByMood : NSObject {
    // the mood of the object
    public var mood:SpotifyAnalysisViewModel.Moods
    
    // the track ids associated with the mood
    public var trackIds:[String]
    
    init(mood: SpotifyAnalysisViewModel.Moods, Ids: [String]) {
        self.mood = mood
        self.trackIds = Ids
    }
}

class RecommendationSeedCacheManager {
    // the cache manager
    private let cache = NSCache<NSString, TracksByMood>()
}
