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
    var total = 0
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
    let songIds = ["5uu28fUesZMl89lf9CLrgN", "7nwGvxqSrgAuty1tlPGCFz", "7iQM9DQUFKUSNjVt8GQZV2",
    "4YHkUrSYE0xzUqp7noMUWD", "7KT7VGnPU5QVXN3q1BOeqb"]
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
        for id in songIds{
            Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id    )){ [weak self] result in
                switch result {
                case .success(let graphQLResult):
                    if let analyzedSongs = graphQLResult.data?.spotifyTrack {
                        DispatchQueue.main.async {
                            self?.analyzedSongs.append(SpotifyAnalysisViewModel.init(analyzedSpotifyTrack: analyzedSongs))
                            self?.networkCalls.cyanite += 1
                            self?.networkCalls.total += 1
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
    
//    var audioAnalysis: [] {
//        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished!.result
//    }
    
    init(analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack) {
        self.analyzedSpotifyTrack = analyzedSpotifyTrack
    }
    
}
