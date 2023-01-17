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

// the URI for artists
class artistURI: SpotifyURIConvertible {
    public var uri:String
    
    init(URI artistUri:String){
        self.uri = "spotify:artist:\(artistUri)"
    }
}

struct SpotifyAnalysisScreen: View{
        
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
    
    // store an alert
    @State private var alert: AlertItem? = nil
    
    // the mood to analyze
    private var selectedMood:SpotifyAnalysisViewModel.Moods?
    
    // the genre to generate the playlist from
    private var selectedGenre:NSString = "edm"
    
    // the network retry listener
    private var artistRetryHandler = Event<Node<String>?>()
    
    // the playlist creation listener
    private var playlistListener = Event<Bool>()
    
    // the created playlist uri
    @State private var createdPlaylistId:String = ""

    // initializer
    init(mood:SpotifyAnalysisViewModel.Moods?) {
        self._recommendedTracks = State(initialValue: [])
        selectedMood = mood
    }
    // preview initializer
    fileprivate init(recommendedTracks: [Track]) {
        self._recommendedTracks = State(initialValue: recommendedTracks)
        selectedMood = nil
    }
    
    var body: some View {
        VStack{
            if recommendedTracks.isEmpty &&
                analyzedSongListVM.seedIds.isEmpty {
                HStack {
                    ProgressView()
                        .padding()
                    Text("Loading Tracks")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .onAppear(perform: {
                    getRecommendations()
                })
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
                            .foregroundColor(Color.black)
                            .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                            .font(Font.headline.weight(.bold))
                            .lineLimit(1)
                    }
                        .disabled($playlist.wrappedValue == "")
                        .background(Color.white)
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
                        Text("Great Success!")
                            .font(.largeTitle)
                    }
                    Divider()
                    Spacer()
                    Button(action: {
                        print("created playlist with id: \(createdPlaylistId)")
                        
                        let spotifyUrl = URL(string: "https://open.spotify.com/playlist/\(createdPlaylistId)")!
                        if UIApplication.shared.canOpenURL(spotifyUrl) {
                            UIApplication.shared.open(spotifyUrl) // open the spotify app
                        }
                        else {
                            // redirect user to app store to install spotfiy
                            print("Spotify app not found!!!")
                        }
                    }){ Text("Open Spotify")
                        .foregroundColor(Color.black)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        .font(Font.headline.weight(.bold))
                        .lineLimit(1)
                    }
                    .background(Color.white)
                    .clipShape(Capsule())
                    .buttonStyle(PlainButtonStyle())
                    .padding(EdgeInsets(top: 50, leading: 100, bottom: 1, trailing: 100))
                    NavigationLink(destination: HomeView()) {
                        Text("Return Home")
                            .foregroundColor(Color.black)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            .font(Font.headline.weight(.bold))
                            .lineLimit(1)
                    }
                        .background(Color.white)
                        .clipShape(Capsule())
                        .buttonStyle(PlainButtonStyle())
                        .padding(EdgeInsets(top: 50, leading: 100, bottom: 1, trailing: 100))
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
                    Button(action: {
                        print("hello")
                    }){ Text("One more try")
                        .foregroundColor(Color.black)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        .font(Font.headline.weight(.bold))
                        .lineLimit(1)
                    }
                    .background(Color.white)
                    .clipShape(Capsule())
                    .buttonStyle(PlainButtonStyle())
                    .padding(EdgeInsets(top: 50, leading: 100, bottom: 1, trailing: 100))
                    NavigationLink(destination: HomeView()) {
                        Text("Return Home")
                            .foregroundColor(Color.black)
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            .font(Font.headline.weight(.bold))
                            .lineLimit(1)
                    }
                        .background(Color.white)
                        .clipShape(Capsule())
                        .buttonStyle(PlainButtonStyle())
                        .padding(EdgeInsets(top: 50, leading: 100, bottom: 1, trailing: 100))
                        .navigationBarHidden(true)
                }
            }
            Spacer()
            Button(action: {analyzedSongListVM.printNetworkCalls()}){
                Text("Print network calls")
            }
        }
        .onAppear{
            artistRetryHandler.addHandler {data in networkRetryHandler(Ids: data)}
            analyzedSongListVM.initialize(listener: artistRetryHandler)
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
        if !analyzedSongListVM.loadMoodFromDatabase(mood: selectedMood!, genre: selectedGenre as String){
            getUserTopArtists() // download mood seed from network
        }
    }
    
    func getRecommendations() {
        let trackURIs:[String] = analyzedSongListVM.seedIds.map {"spotify:track:\($0)" }
        self.getRecommendationsCancellable = self.spotify.api
            .recommendations(TrackAttributes(seedTracks: trackURIs), limit: 10)
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
    
    func writeTracks() {
        let ids = self.recommendedTracks.map { $0.id! }
        if !ids.isEmpty {
            analyzedSongListVM.writeMoodToDataBase(
                mood: selectedMood!, genre: selectedGenre as String, withIds: ids)
        }
    }
}

// Generate the seeds for the cache
extension SpotifyAnalysisScreen {
    
    func getUserTopArtists() {
        var artistIds:[String] = []
        self.getUserTopArtistsCancellable = self.spotify.api
            .currentUserTopArtists(limit:10)
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
                for artist in response {
                    if let genres = artist?.genres {
                        for genre in genres {
                            if genre == selectedGenre as String {
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
                getArtistTopTracks(withIds: artists.head)
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
                        mood: mood, genre: selectedGenre as String,
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
                SpotifyAnalysisScreen(recommendedTracks: tracks)
                    .listStyle(PlainListStyle())
            }
        }
    }
}