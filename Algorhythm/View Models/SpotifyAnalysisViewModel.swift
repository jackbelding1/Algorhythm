/**
 * SpotifyAnalysisViewModel.swift
 * Created by Jack Belding on 10/12/22.
 */

import Foundation
import Apollo
import Combine
import SpotifyWebAPI
import SpotifyExampleContent

// for debugging
struct NetworkCalls {
    var spotify: Int = 0
    var cyanite: Int = 0
    var total: Int { spotify + cyanite }
}

class SpotifyAnalysisViewModel: ObservableObject {
    
    enum PlaylistCreationState {
        case inProgress
        case waitingRequest
        case success
        case failure
    }
    
    var recommendedTracks: [Track] = []
    
    @Published var playlistCreationState: PlaylistCreationState = .waitingRequest
    
    @Published var alert: AlertItem? = nil
    @Published var isLoadingPage: Bool = false
    
    // Network calls logger
    public var networkCalls:NetworkCalls = NetworkCalls()
    
    // the list of analyzed songs
    @Published var analyzedSongs: [SpotifyAnalysisModel] = []
    
    // songs to analyze
    private var songIds:[String:String] = [:]
    
    // the realm database manager
    private let algoDbManager = AlgoDataManager()
    
    private let spotifyAnalysisRepository: SpotifyAnalysisRepository
    
    // the list of seed ids for the selected mood and genre
    @Published var seedIds:[String] = []

    
    init(spotify: Spotify) {
        spotifyAnalysisRepository = SpotifyAnalysisRepository(spotify: spotify)
    }
    
    
    func handleCompletion(
        _ completion: Subscribers.Completion<Error>,
        title: String,
        updatePlaylistState: Bool = false,
        updateLoadingPage: Bool = false
    ) {
        if case .failure(let error) = completion {
            if updatePlaylistState {
                playlistCreationState = .failure
            }
            print("\(title): \(error)")
            alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
            if updateLoadingPage {
                isLoadingPage = false
            }
        }
    }
    
    func createPlaylistCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't create playlist", updatePlaylistState: true)
    }
    
    func addTracksCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't add items", updatePlaylistState: true)
    }
    
    func getRecommendationsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't retrieve recommendations")
    }
    
    func getTopArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't retrieve user top artists", updateLoadingPage: true)
    }
    
    func getArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        handleCompletion(completion, title: "Couldn't retrieve artists", updateLoadingPage: true)
    }
    
    func getArtistTopTracksCompletion(
        _ completion: Subscribers.Completion<Error>
    ){
        handleCompletion(completion, title: "Couldn't retrieve artist top tracks", updateLoadingPage: true)
    }
}

/**
 * utility functions
 */
extension SpotifyAnalysisViewModel {
    
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
    
    func getAnalyzedMoodSeeds(bymood mood:SpotifyAnalysisModel.Moods?) -> [String] {
        var filteredTracks: [SpotifyAnalysisModel] = []
        if mood != nil {
            for track in analyzedSongs {
                if track.maxMoods.isInList(mood!) {
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
extension SpotifyAnalysisViewModel{    
    func findMoodGenreTrack(mood selectedMood:String,
                            genre selectedGenre:String, tracks artistTracks:Node<String?>?, parentNode node:Node<String>?) {
        if let head = artistTracks {
            if let id = head.value {
                Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id)) { [weak self] result in
                    switch result {
                    case .success(let graphQLResult):
                        if let analyzedTrack = graphQLResult.data?.spotifyTrack {
                            if let secondOptional = analyzedTrack.resultMap["__typename"] as? String {
                                if secondOptional == "SpotifyTrackError" {
                                    self?.findMoodGenreTrack(mood: selectedMood, genre: selectedGenre,
                                                             tracks: head.next, parentNode: node)
                                    return
                                }
                            } else {
                                print("Value is not of the expected type or is nil.")
                            }
                            DispatchQueue.main.async {
                                self?.analyzedSongs.append(SpotifyAnalysisModel.init(analyzedSpotifyTrack: analyzedTrack))
                            }
                        }
                        let res = self?.filterForWriting(mood: selectedMood, genre: selectedGenre, analyzedTracks: self?.analyzedSongs)
                        if res! {
                            // raise event handler to generate recommendations
//                            self?.recommendationListener.raise(data: {print("generate recommendations")}())
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
//            artistRetryListener.raise(data: node?.next)
        }
    }
    // function checks if the analyzed track's genre tags contains the selected genre
    func trackIsSelectedGenre(_ track:SpotifyAnalysisModel, genre selectedGenre:String) -> Bool {
        if let cyaniteGenreTags = track.genreTags {
            for trackGenreTag in cyaniteGenreTags {
                if cyanite2SpotfiyTags[trackGenreTag.rawValue]!.contains(selectedGenre){
                    return true
                }
            }
            return false
        }
        else {
            return false
        }
    }
    // temporary function to map moods that don't have a UI button
    func mapMoods(_ mood:String) -> [String]{
        var moods = [mood]
        if mood == "uplifitng" {
            moods.append("happy")
        }
        else if mood == "chilled" || mood == "ethereal" {
            moods.append("calm")
        }
        else if mood == "epic" {
            moods.append("energetic")
        }
        else if mood == "scary" {
            moods.append("dark")
        }
        return moods
    }
    
    // function checks if the analyzed track's mood tag contains the selected mood
    func trackIsSelectedMood(_ track:SpotifyAnalysisModel,mood selectedMood:String) -> Bool {
        if let cyaniteMoodTags = track.moodTags {
            for trackMoodTag in cyaniteMoodTags {
                if mapMoods(trackMoodTag.rawValue).contains(selectedMood) {
                    return true
                }
            }
            return false
        }
        else {
            return false
        }
    }
    
    /**
     * Search through the provided tracks. When a track's max mood is the selected mood,
     * write to the data base and return
     */
    func filterForWriting(mood selectedMood:String,
                          genre selectedGenre:String, analyzedTracks tracks:[SpotifyAnalysisModel]?) -> Bool{
        if let loc_tracks = tracks {
            for track in loc_tracks {
                if trackIsSelectedMood(track, mood: selectedMood)
                    && trackIsSelectedGenre(track, genre: selectedGenre) {
                    seedIds.append(track.id)
                    writeMoodToDataBase(mood: selectedMood, genre: selectedGenre, withIds: seedIds)
                    return true
                }
            }
        }
        return false
    }
    
    func writePlaylistId(_ id:String) {algoDbManager.writePlaylistId(withId: id)}
    
    func writeMoodToDataBase(mood selectedMood:String,
                             genre selectedGenre:String, withIds Ids:[String]) {
        algoDbManager.writeIds(forGenre: selectedGenre, forMood: selectedMood, ids: Ids)
    }
    
    func loadMoodFromDatabase(mood selectedMood:String,
                              genre selectedGenre:String) -> Bool {
        // try to load from the data manager. if ids are found, append to the
        // list and return true. if empty ids, return false
        let ids = algoDbManager.readIds(forGenre: selectedGenre, forMood: selectedMood)
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
}
