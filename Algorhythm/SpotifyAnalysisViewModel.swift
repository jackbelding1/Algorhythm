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

    // the realm database manager
    private let algoDbManager = AlgoDataManager()
    
    // the list of seed ids for the selected mood and genre
    @Published var seedIds:[String] = []
    
    // the event listener
    private var eventListener:Event<Node<String>?>? = nil
    
    // the get recommendations function callback
    private var recommendationListener:Event<Void>? = nil
    /**
     * initialize listeners
     * @param retryListener: The artist top items retry handler
     * @param recommendationsListener: The callback function to get recommended tracks
     */
    func initialize(retryListener:Event<Node<String>?>, recommendationListener:Event<Void>){
        self.eventListener = retryListener
        self.recommendationListener = recommendationListener
        
    }
    
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
}
/**
 * Filter seeds by mood
 */
extension SpotifyAnalysisListViewModel{    
    func findMoodGenreTrack(mood selectedMood:SpotifyAnalysisViewModel.Moods,
                            genre selectedGenre:String, tracks artistTracks:Node<String?>?, parentNode node:Node<String>?) {
        if let head = artistTracks {
            if let id = head.value {
                Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id)) { [weak self] result in
                    switch result {
                    case .success(let graphQLResult):
                        if let analyzedTrack = graphQLResult.data?.spotifyTrack {
                            DispatchQueue.main.async {
                                self?.analyzedSongs.append(SpotifyAnalysisViewModel.init(analyzedSpotifyTrack: analyzedTrack))
                            }
                        }
                        let res = self?.filterForWriting(mood: selectedMood, genre: selectedGenre, analyzedTracks: self?.analyzedSongs)
                        if res! {
                            // raise event handler to generate recommendations
                            self?.recommendationListener?.raise(data: {print("generate recommendations")}())
                            return
                        }
                        else {
                            self?.findMoodGenreTrack(mood: selectedMood, genre: selectedGenre,
                                                     tracks: head.next, parentNode: node)
                        }
                    case .failure(let error):
                        print("error")
                    }
                }
                self.networkCalls.cyanite += 1
            }
            
        }
        else {
            // we need to call get artist Top tracks again, with the parent head.
            // we will pass the parent head in to the function, then use it while calling the parent function
            eventListener?.raise(data: node?.next)
        }
    }
    
    /**
     * Search through the provided tracks. When a track's max mood is the selected mood,
     * write to the data base and return
     */
    func filterForWriting(mood selectedMood:SpotifyAnalysisViewModel.Moods,
                          genre selectedGenre:String, analyzedTracks tracks:[SpotifyAnalysisViewModel]?) -> Bool{
        if let loc_tracks = tracks {
            for track in loc_tracks {
                if track.maxMood == selectedMood {
                    seedIds.append(track.id)
                    writeMoodToDataBase(mood: selectedMood, genre: selectedGenre, withIds: seedIds)
                    return true
                }
            }
        }
        return false
    }
    
    func writePlaylistId(_ id:String) {algoDbManager.writePlaylistId(withId: id)}
    
    func writeMoodToDataBase(mood selectedMood:SpotifyAnalysisViewModel.Moods,
                         genre selectedGenre:String, withIds Ids:[String]) {
        algoDbManager.writeIds(forGenre: selectedGenre, forMood: enumToString(selectedMood)!, ids: Ids)
    }
    
    func loadMoodFromDatabase(mood selectedMood:SpotifyAnalysisViewModel.Moods,
                          genre selectedGenre:String) -> Bool {
        // try to load from the data manager. if ids are found, append to the
        // list and return true. if empty ids, return false
        if let mood = enumToString(selectedMood){
            let ids = algoDbManager.readIds(forGenre: selectedGenre, forMood: mood)
            if ids.isEmpty {
                return false
            }
            else {
                for id in ids {
                    seedIds.append(id)
                }
                return true
            }
        }
        return false
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
