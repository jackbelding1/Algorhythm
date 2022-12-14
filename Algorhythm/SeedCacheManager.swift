//
//  SeedCacheManager.swift
//  Algorhythm
//
//  Created by Jack Belding on 11/24/22.
//

import Foundation
/**
 * cache entry object
 */
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
        var dict = [mood:Ids]
        self.tracksByMood = dict
    }
}

final class RecommendationSeedCacheManager {
    // the cache manager
    private let cache = NSCache<NSString, genreMoods>()
    
    func getFromCache(genre:NSString, mood:SpotifyAnalysisViewModel.Moods) -> [String]? {
        guard let moods = cache.object(forKey: genre) else { return nil }
        return moods.getTrackIds(byMood: mood)
    }
    
    func putIntoCache(genre:NSString, mood:SpotifyAnalysisViewModel.Moods, Ids:[String]) {
        // check if genre exists as a key
        if let moods = cache.object(forKey: genre) {
            for Id in Ids {
                moods.putTrackId(intoMood: mood, id: Id)
            }
            cache.setObject(moods, forKey: genre)
        }
        else {
            var moods = genreMoods(mood: mood, Ids: Ids)
            cache.setObject(moods, forKey: genre)
        }
    }
    
    // add the first matching track id to the cache
    func filterForCaching(mood selectedMood:SpotifyAnalysisViewModel.Moods,
                          genre selectedGenre:String, analyzedTracks tracks:[SpotifyAnalysisViewModel]?) {
        if let loc_tracks = tracks {
            for track in loc_tracks {
                if track.maxMood == selectedMood {
                    putIntoCache(genre: selectedGenre as NSString, mood: selectedMood, Ids: [track.id])
                    print("track cached!!")
                    return
                }
            }
        }
    }
    
    // for testing
    func printContent() {
        guard let moods = cache.object(forKey: "edm") else { return }
        if let Ids = moods.getTrackIds(byMood: SpotifyAnalysisViewModel.Moods.Energetic) {
            for id in Ids {
                print("Id: \(id)")
            }
        }
            
    }
}
