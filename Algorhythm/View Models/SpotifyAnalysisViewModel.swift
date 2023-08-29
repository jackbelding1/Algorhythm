/**
 * SpotifyAnalysisViewModel.swift
 * Created by Jack Belding on 10/12/22.
 */
// MARK: - Imports
import Foundation
import Apollo
import Combine
import SpotifyWebAPI
import SpotifyExampleContent

// MARK: - Debugging Structs
struct NetworkCalls {
    var spotify: Int = 0
    var cyanite: Int = 0
    var total: Int { spotify + cyanite }
}
// MARK: - SpotifyAnalysisViewModel
class SpotifyAnalysisViewModel: ObservableObject {
    // MARK: - Enums
    enum PlaylistCreationState {
        case initializing
        case inititializationFailure
        case inProgress
        case enterPlaylistName
        case success
        case failure
    }
    
    // MARK: - Variables
    @Published var playlistCreationState: PlaylistCreationState = .initializing
    @Published var createdPlaylistId: String = ""
    @Published var alert: AlertItem? = nil
    @Published var analyzedSongs: [SpotifyAnalysisModel] = []
    @Published var recommendationSeedIds: [String] = []
    public var recommendedTracks: [Track] = []
    public var networkCalls: NetworkCalls = NetworkCalls()
    private let spotifyRepository: SpotifyRepository
    private let realmRepository = RealmRepository()
    private let mood: String
    private let genre: String
    private var artistOffset: Int = 0
    private var currentTimeRange: TimeRange = TimeRange.shortTerm
    private var retryCounter: Int = 1

    // MARK: - Initializers
    init(spotify: Spotify, withMood mood: String, withGenre genre: String) {
        self.mood = mood
        self.genre = genre
        spotifyRepository = SpotifyRepository(spotify: spotify)
        generateRecommendations()
    }
    
    // MARK: - Public Methods
    func recommendedTracksEmpty() -> Bool { return recommendedTracks.isEmpty }
    func getAnalyzedSongsCount() -> Int { return analyzedSongs.count }
    func openSpotify() { spotifyRepository.openPlaylistURL(playlistId: createdPlaylistId) }
    
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
        )
    }
    
    // MARK: - Private Methods
    private func generateRecommendations() {
        getSavedSeeds()
        
        if recommendationSeedIds.isEmpty {
            getUserTopArtists(
                timeRange: currentTimeRange,
                offset: artistOffset,
                limit: 50) // download mood seed from network
        } else {
            getRecommendedTracks()
        }
    }
    
    private func getSavedSeeds() {
        // try to load from the data manager. if ids are found, append to the
        // list and return true. if empty ids, return false
        let ids = realmRepository.readTrackIds(forGenre: genre, forMood: mood)
        for id in ids {
            recommendationSeedIds.append(id)
        }
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
    
    // function checks if the analyzed track's genre tags contains the selected genre
    private func trackIsSelectedGenre(_ track:SpotifyAnalysisModel) -> Bool {
        if let cyaniteGenreTags = track.genreTags {
            for trackGenreTag in cyaniteGenreTags {
                if cyaniteToSpotfiyTags[trackGenreTag.rawValue]!.contains(genre) {
                    return true
                }
            }
            return false
        }
        else {
            return false
        }
    }

    /// Maps a given mood to a related mood.
    ///
    /// - Parameter mood: The original mood as a string.
    /// - Returns: An array containing the original mood and the mapped mood.
    private func mapMoods(_ mood: String) -> [String] {
        let moodMapping: [String: String] = [
            "uplifting": "happy",
            "chilled": "calm",
            "ethereal": "calm",
            "epic": "energetic",
            "scary": "dark"
        ]
        
        var moods = [mood]
        
        if let mappedMood = moodMapping[mood] {
            moods.append(mappedMood)
        }
        
        return moods
    }
    
    // function checks if the analyzed track's mood tag contains the selected mood
    private func trackIsSelectedMood(_ track:SpotifyAnalysisModel) -> Bool {
        if let cyaniteMoodTags = track.moodTags {
            for trackMoodTag in cyaniteMoodTags {
                if mapMoods(trackMoodTag.rawValue).contains(mood) {
                    return true
                }
            }
            return false
        }
        else {
            return false
        }
    }

    private func songIsSelectedMoodAndGenre() -> String? {
        for track in self.analyzedSongs {
            if trackIsSelectedMood(track) && trackIsSelectedGenre(track) {
                return track.id
            }
        }
        return nil
    }
    
    // function checks if the retry counter will satisfy a network rety
    private func getTopArtistRetry() {
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
}

// MARK: - Networking Methods
extension SpotifyAnalysisViewModel {
    private func getRecommendedTracks() { spotifyRepository.getRecommendations(
        trackURIs: recommendationSeedIds.map { "spotify:track:\($0)" },
        completion: getRecommendationsCompletion(_:))
    }
    
    private func getUserTopArtists(timeRange: TimeRange, offset: Int, limit: Int) {
        playlistCreationState = .inProgress
        spotifyRepository.getUserTopArtists(
            timeRange: timeRange, offset: offset,
            limit: limit, completion: getTopArtistsCompletion(_:))
    }
    
    private func getArtistTopTracks(withIds Ids:Node<String>?) {
        guard let head = Ids else { return }
        spotifyRepository.getArtistTopTracks(
            artistId: head.value, completion: getArtistTopTracksCompletion(_:))
    }
    
    private func addTracksToPlaylist(playlistURI: String) {
        let trackURIs = recommendedTracks.map { "spotify:track:\($0.id!)" }
        spotifyRepository.addToPlaylist(
            playlistURI: playlistURI, uris: trackURIs,
            completion: addTracksCompletion(_:)
        )
    }
    
    private func analyzeSpotifyTrack(tracks artistTracks: Node<String?>?) {
        guard let head = artistTracks, let id = head.value else {
            // Handle the case when artistTracks is nil or head.value is nil
            //
            // TODO: call network retry handler
            //
            return
        }
        
        spotifyRepository.analyzeSpotifyTrack(by: id) { [weak self] result in
            self?.spotifyTrackAnalysisHandler(result: result, head: head)
        }
    }
}

// MARK: - Completion Handlers
extension SpotifyAnalysisViewModel {
    
    private func spotifyTrackAnalysisHandler(result: Result<SpotifyTrackQueryQuery.Data.SpotifyTrack, Error>, head: Node<String?>) {
        switch result {
        case .success(let analyzedTrack):
            if isTrackError(analyzedTrack) {
                analyzeSpotifyTrack(tracks: head.next)
                return
            }
            analyzedSongs.append(SpotifyAnalysisModel.init(analyzedSpotifyTrack: analyzedTrack))
            
            if let trackId = songIsSelectedMoodAndGenre() {
                recommendationSeedIds.append(trackId)
                getRecommendedTracks()
                realmRepository.writeTrackIds(forGenre: genre, forMood: mood, ids: recommendationSeedIds) // save to disk
            } else {
                analyzeSpotifyTrack(tracks: head.next)
            }
        case .failure(let error):
            print("Error occurred: \(error.localizedDescription)")
        }
    }

    private func isTrackError(_ analyzedTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack) -> Bool {
        if let secondOptional = analyzedTrack.resultMap["__typename"] as? String, secondOptional == "SpotifyTrackError" {
            return true
        }
        print("Value is not of the expected type or is nil.")
        return false
    }
    
    private func createPlaylistCompletion(
        _ result: Result<Playlist<PlaylistItems>, Error>
    ) {
        switch result {
        case .success(let playlist):
            addTracksToPlaylist(playlistURI: playlist.uri)
            realmRepository.writePlaylist(withId: playlist.id)
            createdPlaylistId = playlist.id
        case .failure(let error):
            print("Couldn't create playlists: \(error)")
            alert = AlertItem(
                title: "Couldn't create playlists",
                message: error.localizedDescription
            )
        }
    }
    
    private func addTracksCompletion(
        _ result: Result<Void, Error>
    ) {
        switch result {
        case .success:
            playlistCreationState = .success
        case .failure(let error):
            // Handle error
            playlistCreationState = .failure
        }
    }
    
    private func getRecommendationsCompletion(
        _ result: Result<[Track], Error>
    ) {
        switch result {
        case .success(let tracks):
            recommendedTracks = tracks // Assigning the tracks to the member variable
            playlistCreationState = .enterPlaylistName
        case .failure(let error):
            playlistCreationState = .inititializationFailure
            print("Couldn't retrieve recommendations: \(error)")
            alert = AlertItem(
                title: "Couldn't retrieve recommendations",
                message: error.localizedDescription
            )
        }
    }
    
    private func getTopArtistsCompletion(_ result: Result<[Artist], Error >) {
        switch result {
        case .success(let artists):
            let linkedListOfArtists = self.createLinkedList(ofArtists: artists, matchingGenre: genre)
            getArtistTopTracks(withIds: linkedListOfArtists.head)
            
        case .failure(let error):
            playlistCreationState = .inititializationFailure
            print("Couldn't retrieve user top artists: \(error)")
            alert = AlertItem(
                title: "Couldn't retrieve user top artists",
                message: error.localizedDescription
            )
        }
    }
    
    private func getArtistTopTracksCompletion(
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
            analyzeSpotifyTrack(tracks: tracks.head)
        case .failure(let error):
            // Handle the error
            print("Couldn't retrieve top tracks: \(error)")
            playlistCreationState = .inititializationFailure
        }
    }

}
