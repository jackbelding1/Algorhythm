//
//  SpotifyAnalysisViewModel.swift
//  XcodersGraphQL
//
//  Created by Jack Belding on 10/12/22.
//

import Foundation
import Apollo

struct NetworkCalls{
    var spotify:Int = 0
    var cyanite:Int = 0
    var total = 0
}


class SpotifyAnalysisListViewModel: ObservableObject {
    // Network calls logger
    private var networkCalls:NetworkCalls = NetworkCalls()
    func printNetworkCalls() -> Void {
        print("""
              ###########################################\n
              NETWORK CALLS LOGGER\n
              cyanite: \(networkCalls.cyanite)\nspotify:\(networkCalls.spotify)
              total: \(networkCalls.total)\n
              ###########################################\n
              """)
    }
    
    @Published var analyzedSongs: [SpotifyAnalysisViewModel] = []
    let songIds = ["5uu28fUesZMl89lf9CLrgN", "7nwGvxqSrgAuty1tlPGCFz", "7iQM9DQUFKUSNjVt8GQZV2",
    "4YHkUrSYE0xzUqp7noMUWD", "7KT7VGnPU5QVXN3q1BOeqb"]
    
    func populateRecentlyPlayedSongAnalysis() {
        // get track analysis
        for id in songIds{
            Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id	)){ [weak self] result in
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
