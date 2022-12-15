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

    // spotify object
    @EnvironmentObject var spotify: Spotify

    // View model for mood analysis and data storage
    @StateObject private var analyzedSongListVM = SpotifyAnalysisListViewModel()
    
    // display loading page
    @State private var isLoadingPage = false
    
    // the array of user top tracks to be filtered for moods
    @State private var userTopTracks: [Track]
    
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
    
    // the event listener
    private var eventListener = Event<Node<String>?>()

    // initializer
    init(mood:SpotifyAnalysisViewModel.Moods?) {
        self._userTopTracks = State(initialValue: [])
        self._recommendedTracks = State(initialValue: [])
        selectedMood = mood
    }
    // preview initializer
    fileprivate init(topTracks: [Track], recommendedTracks: [Track]) {
        self._userTopTracks = State(initialValue: topTracks)
        self._recommendedTracks = State(initialValue: recommendedTracks)
        selectedMood = nil
    }
    var body: some View {
        NavigationView{
            VStack{
                Group{
                    if recommendedTracks.isEmpty{
                        if analyzedSongListVM.seedIds.isEmpty {
                            HStack {
                                ProgressView()
                                    .padding()
                                Text("Loading Tracks")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                        else {
                            Button(action: {getRecommendations()}){
                                Text("Generate Recommendations")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    else {
                        // show user top tracks
                        ForEach(
                            recommendedTracks,
                            id: \.self
                        ){item in
                            TrackView(track: item)
                        }
                        .overlay(alignment: .bottom) {
                            PopupView()
                        }
                        .ignoresSafeArea()
                        Spacer()
                        
                    }
                }
                Spacer()
                Button(action: {analyzedSongListVM.printNetworkCalls()}){
                    Text("Print network calls")
                }
            }
        }
        .onAppear{
            eventListener.addHandler {data in networkRetryHandler(Ids: data)}
            analyzedSongListVM.initialize(listener: eventListener)
            getSeeds(genreIsSelected: false)
        }
        .navigationTitle("User top tracks")
        .padding()
    }
}

extension SpotifyAnalysisScreen {
    
    func getSeeds(genreIsSelected:Bool) {
        if !genreIsSelected {
            //
            // TODO: generate normalized genre
            //
        }
        if !analyzedSongListVM.loadFromDatabase(mood: selectedMood!, genre: selectedGenre as String){
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
    
    func createPlaylistFromRecommendations() {
        var playlistURI:String = ""
        if let currentUser = spotify.currentUser?.id {
            self.createPlaylistCancellable = self.spotify.api
                .createPlaylist(for: currentUser, PlaylistDetails(name: "algorhythm test", isPublic: false, isCollaborative: false, description: "dudes be like subway sucks"))
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: self.createPlaylistCompletion(_:),
                    receiveValue: {
                        response in
                    playlistURI = response.uri
                    if !playlistURI.isEmpty {
                        let trackURIs:[String] = recommendedTracks.map {"spotify:track:\($0.id!)" }
                        self.addTracksCancellable = self.spotify.api
                            .addToPlaylist(playlistURI, uris: trackURIs)
                            .receive(on: RunLoop.main)
                            .sink(receiveCompletion: self.addTracksCompletion(_:),
                                  receiveValue: {
                                response in
                                print("Ids added to playlist")
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
            analyzedSongListVM.writeToDataBase(
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
                SpotifyAnalysisScreen(topTracks: tracks, recommendedTracks: tracks)
                    .listStyle(PlainListStyle())
            }
        }
        .environmentObject(Spotify())
    }
}
