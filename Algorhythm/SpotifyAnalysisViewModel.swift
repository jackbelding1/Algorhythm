//
//  SpotifyAnalysisViewModel.swift
//  XcodersGraphQL
//
//  Created by Jack Belding on 10/12/22.
//

import Foundation
import Apollo

class SpotifyAnalysisListViewModel: ObservableObject {
    @Published var analyzedSongs: [SpotifyAnalysisViewModel] = []
    let songIds = ["5uu28fUesZMl89lf9CLrgN"]
    func populateRecentlyPlayedSongAnalysis() {
        // get track analysis
        Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery()){ [weak self] result in
            switch result {
            case .success(let graphQLResult):
               if let analyzedSongs = graphQLResult.data?.spotifyTrack {
                    DispatchQueue.main.async {
                        self?.analyzedSongs.append(SpotifyAnalysisViewModel.init(analyzedSpotifyTrack: analyzedSongs))
                    }
                }
            case .failure(let error):
                print("error")
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
