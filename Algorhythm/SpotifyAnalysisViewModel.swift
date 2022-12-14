/**
 * SpotifyAnalysisViewModel.swift
 * Created by Jack Belding on 10/12/22.
 */

import Foundation
import Apollo
import Combine
import SpotifyWebAPI
import SpotifyExampleContent

/**
 * object to keep count of network calls
 */
struct NetworkCalls{
    var spotify:Int = 0
    var cyanite:Int = 0
    var total:Int {
        return self.spotify + self.cyanite
    }
}

/**
 *  The list of all the analyzed spotify songs. This is only for observing the results of the analysis
 * and will not be used in the production application
 */
class SpotifyAnalysisListViewModel: ObservableObject {
    // Network calls logger
    public var networkCalls:NetworkCalls = NetworkCalls()
    
    // the list of analyzed songs
    @Published var analyzedSongs: [SpotifyAnalysisViewModel] = []
    
    // songs to analyze
    private var songIds:[String:String] = [:]
    
    // the cache manager for recommendation seeds
    private let cache:RecommendationSeedCacheManager = RecommendationSeedCacheManager()
    
}

/**
 * utility functions
 */
extension SpotifyAnalysisListViewModel {
    
    func getAnalyzedSongsCount() -> Int { return analyzedSongs.count }
    
    // print the contents of the network call logger
    func printNetworkCalls() -> Void {
        print("""
              ###########################################\n
              NETWORK CALLS LOGGER\n
              cyanite: \(networkCalls.cyanite)\nspotify:\(networkCalls.spotify)
              total: \(networkCalls.total)\n
              ###########################################\n
              """)
    }
    
    func setSongIds(songIds Ids:[String:String]) { songIds = Ids }
    
    func getAnalyzedMoodSeeds(bymood mood:SpotifyAnalysisViewModel.Moods?) -> [String] {
        var filteredTracks: [SpotifyAnalysisViewModel] = []
        if mood != nil {
            for track in analyzedSongs {
                if track.maxMood == mood {
                    filteredTracks.append(track)
                }
            }
        }
        let filteredTrackIds = filteredTracks.map { $0.id }
        print("Found \(filteredTrackIds.count) items with the selected mood")
        for trackid in filteredTrackIds{
            print("id: \(trackid)")
        }
        return filteredTrackIds
    }
    
    func retrieveCachedMoodSeeds(genre:NSString, mood:SpotifyAnalysisViewModel.Moods) -> [String]? {
        return cache.getFromCache(genre: genre, mood: mood)
    }
    
    func printCacheContents() {
        cache.printContent()
    }
}
/**
 * Filter seeds by mood
 */
extension SpotifyAnalysisListViewModel{    
    func findMoodGenreTrack(mood selectedMood:SpotifyAnalysisViewModel.Moods,
                            genre selectedGenre:String, tracks artistTracks:[Track]) {
        var count:Int = 0
        for track in artistTracks {
                if let id = track.id {
                Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id)) { [weak self] result in
                    switch result {
                    case .success(let graphQLResult):
                        if let analyzedTrack = graphQLResult.data?.spotifyTrack {
                            DispatchQueue.main.async {
                                self?.analyzedSongs.append(SpotifyAnalysisViewModel.init(analyzedSpotifyTrack: analyzedTrack))
                            }
                        }
                        count += 1
                        if count == artistTracks.count {
                            self?.cache.filterForCaching(mood: selectedMood, genre: selectedGenre, analyzedTracks: self?.analyzedSongs)
                        }
                    case .failure(let error):
                        print("error")
                    }
                }
                self.networkCalls.cyanite += 1
            }
        }
    }
}

/**
 *  This represents an analyzed spotify song to be used as a seed. This will be
 *  used for each generation, and will potentially be saved into the mood cache
 */
class SpotifyAnalysisViewModel {
    
    let analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack
    
    var id: String {
        analyzedSpotifyTrack.asSpotifyTrack!.id
    }
        
    var maxMood:Moods
    
    init(analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack) {
        self.analyzedSpotifyTrack = analyzedSpotifyTrack
        self.maxMood = Moods.Energetic
        getMaxValue()
    }
    
}

extension SpotifyAnalysisViewModel {
    
    var energetic:Double? {
        analyzedSpotifyTrack.asSpotifyTrack?.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.energetic
    }

    var dark:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.dark
    }

    var happy:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.happy
    }

    var romantic:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.romantic
    }
    
    var calm:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.calm
    }

    var sad:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.sad
    }

    var sexy:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.sexy
    }
    
    var aggressive:Double?  {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.aggressive
    }
    
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
        
    func getMaxValue() -> Double? {
        var max:Double? = 0.0
        
        for mood in Moods.allCases {
            switch mood {
            case .Energetic:
                if let val = energetic {
                    if max! < val {
                        max! = val
                        maxMood = mood
                    }
                }
            case .Aggressive:
                if let val = aggressive {
                    if max! < val {
                        max! = val
                        maxMood = Moods.Aggressive
                    }
                }
            case .Calm:
                if let val = calm {
                    if max! < val {
                        max! = val
                        maxMood = Moods.Calm
                    }
                }
            case .Romantic:
                if let val = romantic {
                    if max! < val {
                        max! = val
                        maxMood = Moods.Romantic
                    }
                }
            case .Dark:
                if let val = dark {
                    if max! < val {
                        max! = val
                        maxMood = Moods.Dark
                    }
                }
            case .Happy:
                if let val = happy {
                    if max! < val {
                        max! = val
                        maxMood = Moods.Happy
                    }
                }
            case .Sad:
                if let val = sad {
                    if max! < val {
                        max! = val
                        maxMood = Moods.Sad
                    }
                }
            case .Sexy:
                if let val = sexy {
                    if max! < val {
                        max! = val
                        maxMood = Moods.Sexy
                    }
                }
            }
        }
        return max
    }
}
