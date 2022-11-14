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
}

/**
 * utility functions
 */
extension SpotifyAnalysisListViewModel {
    
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
}
/**
 * Filter seeds by mood
 */
extension SpotifyAnalysisListViewModel{
    //
    // request to cyanite API to analyze a list of tracks
    //
    func populateRecentlyPlayedSongAnalysis() {
        // get track analysis
        for (id, name) in songIds{
            Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id    )){ [weak self] result in
                switch result {
                case .success(let graphQLResult):
                    if let analyzedSongs = graphQLResult.data?.spotifyTrack {
                        DispatchQueue.main.async {
                            self?.analyzedSongs.append(SpotifyAnalysisViewModel.init(analyzedSpotifyTrack: analyzedSongs, name: name))
                            self?.networkCalls.cyanite += 1
                        }
                    }
                case .failure(let error):
                    print("error")
                }
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
    
    let name:String
    
    var maxMood:String
    
    init(analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack, name:String) {
        self.analyzedSpotifyTrack = analyzedSpotifyTrack
        self.name = name
        self.maxMood = ""
    }
    
}

extension SpotifyAnalysisViewModel {
    
    var energetic:Double? {
        analyzedSpotifyTrack.asSpotifyTrack?.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.energetic
    }

    var dark:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result.mood.dark
    }

    var happy:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result.mood.happy
    }

    var romantic:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result.mood.romantic
    }
    
    var calm:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result.mood.calm
    }

    var sad:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result.mood.sad
    }

    var sexy:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result.mood.sexy
    }
    
    var aggressive:Double?  {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result.mood.aggressive
    }
    
    enum Moods: CaseIterable {
        case Energetic
        case Dark
        case Happy
        case Romantic
        case Sad
        case Sexy
        case Aggressive
        case Calm
    }
        
    func getMaxValue() -> Double? {
        var max:Double? = 0.0
        
        for mood in Moods.allCases {
            switch mood {
            case .Energetic:
                if let val = energetic {
                    if max! < val {
                        max! = val
                        maxMood = "energetic"
                    }
                }
            case .Aggressive:
                if let val = aggressive {
                    if max! < val {
                        max! = val
                        maxMood = "aggressive"
                    }
                }
            case .Calm:
                if let val = calm {
                    if max! < val {
                        max! = val
                        maxMood = "calm"
                    }
                }
            case .Romantic:
                if let val = romantic {
                    if max! < val {
                        max! = val
                        maxMood = "romantic"
                    }
                }
            case .Dark:
                if let val = dark {
                    if max! < val {
                        max! = val
                        maxMood = "dark"
                    }
                }
            case .Happy:
                if let val = happy {
                    if max! < val {
                        max! = val
                        maxMood = "happy"
                    }
                }
            case .Sad:
                if let val = sad {
                    if max! < val {
                        max! = val
                        maxMood = "sad"
                    }
                }
            case .Sexy:
                if let val = sexy {
                    if max! < val {
                        max! = val
                        maxMood = "sexy"
                    }
                }
            }
        }
        return max
    }
}
