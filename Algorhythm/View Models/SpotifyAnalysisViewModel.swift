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
        case initializing
        case inititializationFailure
        case inProgress
        case enterPlaylistName
        case success
        case failure
    }
    
    private let spotifyRepository: SpotifyRepository
    
    // TEMPORARY - should be private
    public var recommendedTracks: [Track] = []
    
    func recommendedTracksEmpty() -> Bool { return recommendedTracks.isEmpty }
    
    @Published var playlistCreationState: PlaylistCreationState = .initializing
    @Published var createdPlaylistId:String = ""
    @Published var alert: AlertItem? = nil
    
    // for debugging
    public var networkCalls:NetworkCalls = NetworkCalls()
    
    @Published var analyzedSongs: [SpotifyAnalysisModel] = []
    
    private let algoDbManager = AlgoDataManager()
    
    @Published var recommendationSeedIds:[String] = []
    
    private let mood:String
    private let genre:String
    private var artistOffset:Int = 0
    private var currentTimeRange:TimeRange = TimeRange.shortTerm
    private var retryCounter:Int = 1
        
    func getAnalyzedSongsCount() -> Int { return analyzedSongs.count }
    
    init(spotify: Spotify, withMood mood:String, withGenre genre:String) {
        self.mood = mood
        self.genre = genre
        spotifyRepository = SpotifyRepository(spotify: spotify)
        initialize()
    }
    
    func initialize() {
        if !loadMoodFromDatabase(){
            getUserTopArtists(
                timeRange: currentTimeRange,
                offset: artistOffset,
                limit: 50
            ) // download mood seed from network
        } else {
            getRecommendedTracks()
        }
    }
        
    func getRecommendedTracks() { spotifyRepository.getRecommendations(
        trackURIs: recommendationSeedIds.map { "spotify:track:\($0)" },
        completion: getRecommendationsCompletion(_:)
    )}
    
    func getUserTopArtists(timeRange: TimeRange, offset: Int, limit: Int) {
        playlistCreationState = .inProgress
        spotifyRepository.getUserTopArtists(
            timeRange: timeRange, offset: offset,
            limit: limit, completion: getTopArtistsCompletion(_:)
        )}
    
    func getArtistTopTracks(withIds Ids:Node<String>?) {
        guard let head = Ids else { return }
        spotifyRepository.getArtistTopTracks(
            artistId: head.value, completion: getArtistTopTracksCompletion(_:)
        )}
    
    func createPlaylist(withPlaylistName name: String?) {
        var playlistDetails = PlaylistDetails(
            name: name ?? "\(mood) + \(genre)",
            isPublic: false,
            isCollaborative: false,
            description: "Thank you for using algorhythm!" // TODO: replace with user input
        )

        spotifyRepository.createPlaylist(
            playlistDetails: playlistDetails,
            completion: createPlaylistCompletion(_:)
        )}

    private func addTracksToPlaylist(playlistURI: String) {
        let trackURIs = recommendedTracks.map { "spotify:track:\($0.id!)" }
        spotifyRepository.addToPlaylist(
            playlistURI: playlistURI, uris: trackURIs,
            completion: addTracksCompletion(_:)
        )}
    
    func createPlaylistCompletion(
        _ result: Result<Playlist<PlaylistItems>, Error>
    ) {
        switch result {
        case .success(let playlist):
            self.addTracksToPlaylist(playlistURI: playlist.uri)
            writePlaylistId(playlist.id)
            self.createdPlaylistId = playlist.id
        case .failure(let error):
            print("Couldn't create playlists: \(error)")
            alert = AlertItem(
                title: "Couldn't create playlists",
                message: error.localizedDescription
            )
        }
    }
    
    func addTracksCompletion(
        _ result: Result<Void, Error>
    ) {
        switch result {
        case .success:
            self.playlistCreationState = .success
        case .failure(let error):
            // Handle error
            playlistCreationState = .failure
        }
    }
    
    func getRecommendationsCompletion(
        _ result: Result<[Track], Error>
    ) {
        switch result {
        case .success(let tracks):
            self.recommendedTracks = tracks // Assigning the tracks to the member variable
            self.playlistCreationState = .enterPlaylistName
        case .failure(let error):
            playlistCreationState = .inititializationFailure
            print("Couldn't retrieve recommendations: \(error)")
            alert = AlertItem(
                title: "Couldn't retrieve recommendations",
                message: error.localizedDescription
            )
        }
    }
    
    func getTopArtistsCompletion(
        _ result: Result<[Artist], Error >
    ) {
        switch result {
        case .success(let artists):
            let linkedListOfArtists = self.createLinkedList(ofArtists: artists, matchingGenre: genre)
            self.getArtistTopTracks(withIds: linkedListOfArtists.head)
            
        case .failure(let error):
            playlistCreationState = .inititializationFailure
            print("Couldn't retrieve user top artists: \(error)")
            alert = AlertItem(
                title: "Couldn't retrieve user top artists",
                message: error.localizedDescription
            )
        }
    }
    
    func getArtistTopTracksCompletion(
        _ result: (Result<[Track], Error>)
    ){
        var tracks: LinkedList<String?> = LinkedList<String?>()
        var createList: Bool = true
        
        switch result {
        case .success(let response):
            let moodValue = self.mood // Directly accessing the mood
            for track in response {
                if createList {
                    let node = Node(value: track.id)
                    tracks.initialize(withNode: node)
                    createList = false
                } else {
                    tracks.append(track.id)
                }
            }
            findMoodGenreTrack(tracks: tracks.head)
        case .failure(let error):
            // Handle the error
            print("Couldn't retrieve top tracks: \(error)")
            playlistCreationState = .inititializationFailure
        }
    }
    
    /// Opens the created playlist in the Spotify app if installed,
    /// or redirects to the App Store to download Spotify if not installed.
    func openSpotify() {
        spotifyRepository.openPlaylistURL(playlistId: createdPlaylistId)
    }
    
    private func createLinkedList(ofArtists artists: [Artist?], matchingGenre selectedGenre: String) -> LinkedList<String> {
        var linkedListOfArtists = LinkedList<String>()
        var isFirstArtist = true
        artists.forEach { artist in
            if let genres = artist?.genres, genres.contains(selectedGenre), let artistId = artist?.id {
                if isFirstArtist {
                    linkedListOfArtists.initialize(withNode: Node(value: artistId))
                    isFirstArtist = false
                } else {
                    linkedListOfArtists.append(artistId)
                }
            }
        }
        return linkedListOfArtists
    }
}
/**
 * Filter seeds by mood
 */
extension SpotifyAnalysisViewModel {
    
    // function checks if the retry counter will satisfy a network rety
    func getTopArtistRetry() {
        // temporary cap at 200 cyanite calls
        if networkCalls.cyanite > 200 {
            currentTimeRange = .shortTerm
            playlistCreationState = .failure
            //
            // TODO: at this point, we must reach out to a top 100 billboard for
            // TODO: a mood seed. This function will be created later
            //
            return
        }
        if retryCounter > 3 {
            retryCounter = 1
            artistOffset = 0
            switch currentTimeRange {
            case .shortTerm:
                currentTimeRange = .mediumTerm
            case .mediumTerm:
                currentTimeRange = .longTerm
            case .longTerm:
                currentTimeRange = .shortTerm
                playlistCreationState = .failure
                //
                // TODO: at this point, we must reach out to a top 100 billboard for
                // TODO: a mood seed. This function will be created later
                //
                return
            }
        }
        else {
            retryCounter += 1
            artistOffset += 50
        }
        getUserTopArtists(
            timeRange: currentTimeRange,
            offset: artistOffset,
            limit: 50
        )
    }
    
    func findMoodGenreTrack(tracks artistTracks:Node<String?>?) {
        if let head = artistTracks {
            if let id = head.value {
                Network.shared.apollo.fetch(query: SpotifyTrackQueryQuery(id: id)) { [weak self] result in
                    switch result {
                    case .success(let graphQLResult):
                        if let analyzedTrack = graphQLResult.data?.spotifyTrack {
                            if let secondOptional = analyzedTrack.resultMap["__typename"] as? String {
                                if secondOptional == "SpotifyTrackError" {
                                    self?.findMoodGenreTrack(tracks: head.next)
                                    return
                                }
                            } else {
                                print("Value is not of the expected type or is nil.")
                            }
                            DispatchQueue.main.async {
                                self?.analyzedSongs.append(SpotifyAnalysisModel.init(analyzedSpotifyTrack: analyzedTrack))
                            }
                        }
                        let res = self?.filterForWriting()
                        if res! {
                            // raise event handler to generate recommendations
                            self?.getRecommendedTracks()
                            return
                        }
                        else {
                            self?.findMoodGenreTrack(tracks: head.next)
                        }
                    case .failure(let error):
                        print("error")
                    }
                }
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
    func filterForWriting() -> Bool {
        for track in self.analyzedSongs {
            if trackIsSelectedMood(track, mood: self.mood)
                && trackIsSelectedGenre(track, genre: self.genre) {
                recommendationSeedIds.append(track.id)
                writeMoodToDataBase(mood: self.mood, genre: self.genre, withIds: recommendationSeedIds)
                return true
            }
        }
        return false
    }
    
    func writePlaylistId(_ id:String) {algoDbManager.writePlaylistId(withId: id)}
    
    func writeMoodToDataBase(mood selectedMood:String,
                             genre selectedGenre:String, withIds Ids:[String]) {
        algoDbManager.writeIds(forGenre: selectedGenre, forMood: selectedMood, ids: Ids)
    }
    
    func loadMoodFromDatabase() -> Bool {
        // try to load from the data manager. if ids are found, append to the
        // list and return true. if empty ids, return false
        let ids = algoDbManager.readIds(forGenre: genre, forMood: mood)
        if ids.isEmpty {
            return false
        }
        else {
            for id in ids {
                recommendationSeedIds.append(id)
            }
            return true
        }
    }
}
