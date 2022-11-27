//
//  SeedCacheManager.swift
//  Algorhythm
//
//  Created by Jack Belding on 11/24/22.
//

import Foundation

final class genreMoods : NSObject {
    
    // each of the genres moods
    private var tracksByMood:[SpotifyAnalysisViewModel.Moods:[String]]
    
    public func putTrackId(intoMood mood:SpotifyAnalysisViewModel.Moods,id trackid:String){
        // check if the mood exists as a key
        if tracksByMood[mood] == nil {
            tracksByMood[mood] = []
        }
        tracksByMood[mood]?.append(trackid)
    }
    
    public func getTrackIds(byMood mood:SpotifyAnalysisViewModel.Moods) -> [String]? {
        // check if the mood exists as a key
        if tracksByMood[mood] != nil {
            return tracksByMood[mood]
        }
        return nil
    }
    
    init(mood: SpotifyAnalysisViewModel.Moods, Ids: [String]) {
        self.tracksByMood = [:]
    }
}

class RecommendationSeedCacheManager {
    // the cache manager
    private let cache = NSCache<NSString, genreMoods>()
    
    func getFromCache(genre:NSString, mood:SpotifyAnalysisViewModel.Moods) -> [String]? {
        guard let moods = cache.object(forKey: genre) else { return nil }
        return moods.getTrackIds(byMood: mood)
    }
    
    func putIntoCache(genre:NSString, mood:SpotifyAnalysisViewModel.Moods, Ids:[String]) {
        guard let moods = cache.object(forKey: genre) else { return }
        for Id in Ids {
            moods.putTrackId(intoMood: mood, id: Id)
        }
    }
}
