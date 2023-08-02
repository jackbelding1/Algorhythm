//
//  SpotifyAnalysisScreen.swift
//
//  Created by Jack Belding on 10/12/22.
//

import Foundation
import SwiftUI
import Combine
import SpotifyWebAPI
import SpotifyExampleContent

struct SpotifyAnalysisScreen: View{
    // the playlist options to be used in playlist generation
    private var playlistOptions:PlaylistOptionsViewModel

    // the playlist creating result
    enum PlaylistState {
        case in_progress
        case waiting_request
        case success
        case failiure
    }
    @State private var playlistCreationState:PlaylistState = .waiting_request
    
    // spotify object
    @EnvironmentObject var spotify: Spotify
    @EnvironmentObject var appState: AppState

    // View model for mood analysis and data storage
    @StateObject private var analyzedSongListVM = SpotifyAnalysisListViewModel()
    
    // the playlist name to print. This will likely become an object
    @State private var playlist:String = ""
    
    // display loading page
    @State private var isLoadingPage = false
    
    // the array recommended tracks generated
    @State private var recommendedTracks: [Track]

    @State private var createPlaylistCancellable: AnyCancellable? = nil
    
    @State private var getRecommendationsCancellable: AnyCancellable? = nil

    @State private var getUserTopArtistsCancellable: AnyCancellable? = nil
    
    @State private var getArtistsCancellable: AnyCancellable? = nil
    
    @State private var getArtistTopTracksCancellable: [AnyCancellable]? = []
    
    @State private var addTracksCancellable: AnyCancellable? = nil
    
    // The text for the link to spotify
    @State private var spotifyButtonText = ""
    
    // store an alert
    @State private var alert: AlertItem? = nil
    
    // the mood to analyze
    private var selectedMood:String?
    
    // the genre to generate the playlist from
    private var selectedGenre:String
    
    // the network retry listener
    private var artistRetryHandler = Event<Node<String>?>()
    
    private var generateRecommendationsHandler = Event<Void>()
    
    // the offset of user artists to analyze
    @State private var artistOffset:Int = 0
    
    // the counter for the amount of retrys we make
    @State private var retryCounter:Int = 1
    
    // the current time range
    @State private var currentTimeRange:TimeRange = TimeRange.shortTerm
    
    // the created playlist uri
    @State private var createdPlaylistId:String = ""

    // initializer
    init(mood:String?, _ playlistOptionsVM:PlaylistOptionsViewModel) {
        playlistOptions = playlistOptionsVM
        self._recommendedTracks = State(initialValue: [])
        selectedMood = mood
        selectedGenre = playlistOptions.getRandomGenre()
    }
    // preview initializer
    fileprivate init(recommendedTracks: [Track], _ playlistOptionsVM:PlaylistOptionsViewModel) {
        self._recommendedTracks = State(initialValue: recommendedTracks)
        playlistOptions = playlistOptionsVM
        selectedMood = nil
        selectedGenre = "edm"
    }
    
    var returnHomeButton : some View {
        Button(action: { appState.rootViewId = UUID() }) {
            Text("Return Home")
                .foregroundColor(Color.primary).colorInvert()
                .padding(EdgeInsets(top: 30, leading: 50, bottom: 30, trailing: 50))
                .font(.title2)
                .lineLimit(1)
        }
            .background(Color.primary)
            .clipShape(Capsule())
            .buttonStyle(PlainButtonStyle())
    }
    
    @Environment(\.colorScheme) var colorScheme
    var spotifyLogo: ImageName {
        colorScheme == .dark ? .spotifyLogoBlack
                : .spotifyLogoWhite
    }
        
    var body: some View {
        VStack{
            if recommendedTracks.isEmpty &&
                analyzedSongListVM.seedIds.isEmpty &&
                (playlistCreationState != .failiure) {
                HStack {
                    ProgressView()
                        .padding()
                    Text("Loading Tracks")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            else {
                switch (playlistCreationState){
                case .waiting_request:
                    Text("Name your playlist!")
                        .font(.title)
                        .padding()
                    TextField(text: $playlist, prompt: Text("Type Here")){}
                        .font(.largeTitle)
                        .padding(EdgeInsets(top: 80, leading: 55, bottom: 1, trailing: 55))
                        .disableAutocorrection(true)
                    
                    Divider()
                    Button(action: {
                        createPlaylistFromRecommendations(withPlaylistName: $playlist.wrappedValue)
                        playlistCreationState = .in_progress
                    }) {
                        Text("Create")
                            .foregroundColor(Color.primary).colorInvert()
                            .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                            .lineLimit(1)
                    }
                        .disabled($playlist.wrappedValue == "")
                        .background(Color.primary)
                        .clipShape(Capsule())
                        .buttonStyle(PlainButtonStyle())
                        .padding(EdgeInsets(top: 50, leading: 100, bottom: 1, trailing: 100))
                case .in_progress:
                    ProgressView()
                        .padding()
                    Text("Creating playlist...")
                        .font(.title)
                        .foregroundColor(.secondary)
                case .success:
                    Spacer()
                    Group{
                        Text("✅")
                            .font(.largeTitle)
                        Text("Success!")
                            .font(.largeTitle)
                    }
                    Divider()
                    Spacer()
                    Button(action: {
                        let spotifyUrl = URL(string: "https://open.spotify.com/playlist/\(createdPlaylistId)")!
                        if UIApplication.shared.canOpenURL(spotifyUrl) {
                            UIApplication.shared.open(spotifyUrl) // open the spotify app
                        }
                        else {
                            if let appStoreURL = URL(string: "https://itunes.apple.com/us/app/apple-store/id324684580") {
                             UIApplication.shared.open(appStoreURL)
                            }
                        }
                        }){ HStack {
                            Image(spotifyLogo)
                                .interpolation(.high)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                            if UIApplication.shared.canOpenURL(URL(string: "https://open.spotify.com/")!){
                                Text("Open Spotify")
                                    .font(.title2)
                                    .foregroundColor(Color.primary).colorInvert()
                                    .padding()
                            } else {
                                Text("Get Spotify Free")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.primary).colorInvert()
                                    .padding()
                            }

                        }
                        .padding()
                    }
                .background(Color.primary)
                .clipShape(Capsule())
                .buttonStyle(PlainButtonStyle())
                returnHomeButton
                case .failiure:
                    Spacer()
                    Group{
                        Text("❌")
                            .font(.largeTitle)
                        Text("Failed to create playlist")
                            .font(.largeTitle)
                    }
                    Divider()
                    Spacer()
                    returnHomeButton
                }
            }
            Spacer()
//            Button(action: {analyzedSongListVM.printNetworkCalls()}){
//                Text("Print network calls")
//            }
        }
        .onAppear{
            generateRecommendationsHandler.addHandler(handler: {getRecommendations()})
            artistRetryHandler.addHandler {data in networkRetryHandler(Ids: data)}
            analyzedSongListVM.initialize(retryListener: artistRetryHandler, recommendationListener: generateRecommendationsHandler)
            getSeeds(genreIsSelected: false)
        }
        .padding()
        .navigationBarHidden(playlistCreationState == PlaylistState.success
                             || playlistCreationState == PlaylistState.failiure)
    }
}

extension SpotifyAnalysisScreen {
    
    func getSeeds(genreIsSelected:Bool) {
        
        // Don't try to load any playlists if we're in preview mode.
        if ProcessInfo.processInfo.isPreviewing { return }
        
        
        if !genreIsSelected {
            //
            // TODO: generate normalized genre
            //
        }
        if !analyzedSongListVM.loadMoodFromDatabase(mood: selectedMood!, genre: selectedGenre){
            getUserTopArtists() // download mood seed from network
        }
        else {
            getRecommendations()
        }
    }
    
    func getRecommendations() {
        let trackURIs:[String] = analyzedSongListVM.seedIds.map {"spotify:track:\($0)" }
        self.getRecommendationsCancellable = self.spotify.api
            .recommendations(TrackAttributes(seedTracks: trackURIs), limit: 30)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: self.getRecommendationsCompletion(_:),
                  receiveValue: {
                response in
                self.recommendedTracks = response.tracks
                analyzedSongListVM.networkCalls.spotify += 1
            })
        
    }
    
    func createPlaylistFromRecommendations(withPlaylistName name:String?) {
        var playlistURI:String = ""
        var playlistDetails:PlaylistDetails
        if let playlistName = name {
            playlistDetails = PlaylistDetails(name: playlistName, isPublic: false, isCollaborative: false, description: "Thank you for using algorhythm!")
        }
        else {
            playlistDetails = PlaylistDetails(name: "algorhythm test", isPublic: false, isCollaborative: false, description: "Thank you for using algorhythm!")
        }
        if let currentUser = spotify.currentUser?.id {
            self.createPlaylistCancellable = self.spotify.api
                .createPlaylist(for: currentUser, playlistDetails)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: self.createPlaylistCompletion(_:),
                    receiveValue: {
                        response in
                    playlistURI = response.uri
                    self.createdPlaylistId = response.id
                    self.analyzedSongListVM.writePlaylistId(response.id)
                    if !playlistURI.isEmpty {
                        let trackURIs:[String] = recommendedTracks.map {"spotify:track:\($0.id!)" }
                        self.addTracksCancellable = self.spotify.api
                            .addToPlaylist(playlistURI, uris: trackURIs)
                            .receive(on: RunLoop.main)
                            .sink(receiveCompletion: self.addTracksCompletion(_:),
                                  receiveValue: {
                                response in
                                self.playlistCreationState = .success
                            }
                        )
                    }
                }
            )
        }
    }
    
    // function checks if the retry counter will satisfy a network rety
    func getTopArtistRetry() {
        // temporary cap at 200 cyanite calls
        if analyzedSongListVM.networkCalls.cyanite > 200 {
            currentTimeRange = .shortTerm
            playlistCreationState = .failiure
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
                playlistCreationState = .failiure
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
        getUserTopArtists()
    }
    
    func writeTracks() {
        let ids = self.recommendedTracks.map { $0.id! }
        if !ids.isEmpty {
            analyzedSongListVM.writeMoodToDataBase(
                mood: selectedMood!, genre: selectedGenre, withIds: ids)
        }
    }
}

// Generate the seeds for the cache
extension SpotifyAnalysisScreen {
    
    func getUserTopArtists() {
        var artistIds:[String] = []
        self.getUserTopArtistsCancellable = self.spotify.api
            .currentUserTopArtists(currentTimeRange, offset: artistOffset, limit: 50)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: self.getTopArtistsCompletion(_:),
                receiveValue: {
                    response in
                    for artist in response.items {
                        artistIds.append(artist.id!)
                    }
                    findArtistWithSelectedGenre(withIds: artistIds)
                })
        
    }
    
    func findArtistWithSelectedGenre(withIds artistIds:[String]) {
        let uris = artistIds.map {artistURI(URI: $0)}
        var artists:LinkedList<String> = LinkedList<String>()
        var createList:Bool = true
        self.getArtistsCancellable = self.spotify.api.artists(uris)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion:
                    self.getArtistsCompletion(_:),
                  receiveValue: { response in
                analyzedSongListVM.networkCalls.spotify += 1
                for artist in response {
                    if let genres = artist?.genres {
                        for genre in genres {
                            if genre == selectedGenre {
                                if let artistId = artist?.id {
                                    if createList {
                                        let node = Node(value: artistId)
                                        artists.initialize(withNode: node)
                                        createList = false
                                    }
                                    else {
                                        artists.append(artistId) // populate linked list
                                    }
                                }
                            }
                        }
                    }
                }
                // if we are at the end of the list, restart the loop by getting user top items with artistOffset
                if artists.head == nil {
                    getTopArtistRetry()
                // otherwise, begin analyzing artist top tracks
                } else {
                    getArtistTopTracks(withIds: artists.head)
                }
            }
        )
    }
    /**
     * function fetches the top tracks for the provided Ids and passes them to
     * the view mdoel for analysis.
     * @param: Ids - The artist ids to analyze
     * @ return bool whether or not a track with the selected mood or genre was found
     * in the artist top tracks
     */
    func getArtistTopTracks(withIds Ids:Node<String>?){
        var tracks:LinkedList<String?> = LinkedList<String?>()
        var createList:Bool = true
        if let head = Ids {
            let Id = head.value
            self.getArtistTopTracksCancellable?.append(  self.spotify.api.artistTopTracks(artistURI(URI: Id), country: "US")
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: self.getArtistTopTracksCompletion(_:),
                      receiveValue: { response in
                if let mood = self.selectedMood {
                    // create linked list from response and pass it to the function
                    for val in response {
                        if createList {
                            let node = Node(value: val.id)
                            tracks.initialize(withNode: node)
                            createList = false
                        }
                        else {
                            tracks.append(val.id)
                        }
                    }
                    analyzedSongListVM.findMoodGenreTrack(
                        mood: mood, genre: selectedGenre,
                        tracks: tracks.head, parentNode: head)
                        print("iteration done")
                    }
                }
            ))
        }
    }
}

/**
 * Event handler functions
 */
extension SpotifyAnalysisScreen {
    
    func networkRetryHandler(Ids:Node<String>?){
        if let node = Ids {
            getArtistTopTracks(withIds: node)
        }
        else {
            print("no seeds matching mood found! try again!")
            getTopArtistRetry()
        }
    }
}

extension SpotifyAnalysisScreen {
    func createPlaylistCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            self.playlistCreationState = .failiure
            let title = "Couldn't create playlist"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
    }
    
    func addTracksCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            self.playlistCreationState = .failiure
            let title = "Couldn't add items"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
    }
    
    func getRecommendationsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            let title = "Couldn't retrieve recommendations"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
    }
    
    func getTopArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            let title = "Couldn't retrieve user top artists"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
        self.isLoadingPage = false
    }
    
    func getArtistsCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            let title = "Couldn't retrieve artists"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
        self.isLoadingPage = false
    }
    
    func getArtistTopTracksCompletion(
        _ completion: Subscribers.Completion<Error>
    ){
        if case .failure(let error) = completion {
            let title = "Couldn't retrieve artist top tracks"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
        self.isLoadingPage = false
    }
}

struct SpotifyAnalysisScreen_Previews: PreviewProvider {

    static let tracks: [Track] = [
        .because, .comeTogether, .faces, .illWind,
        .odeToViceroy, .reckoner, .theEnd, .time
    ]

    static var previews: some View {
        ForEach([tracks], id: \.self) { tracks in
            NavigationView {
                SpotifyAnalysisScreen(recommendedTracks: tracks, PlaylistOptionsViewModel())
                    .listStyle(PlainListStyle())
            }
        }
    }
}
