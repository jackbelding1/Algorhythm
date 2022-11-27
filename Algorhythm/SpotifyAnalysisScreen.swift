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
    // the URI for artists
    class artistURI: SpotifyURIConvertible {
        public var uri:String
        
        init(URI artistUri:String){
            self.uri = "spotify:artist:\(artistUri)"
        }
    }
    
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
    
    // the array of top artist
    private var topArtists:[String] = []

    // cancellable for top tracks api
    @State private var getUserTopTracksCancellable: AnyCancellable? = nil
    
    // cancellable for track recommendation api
    @State private var getRecommendationsCancellable: AnyCancellable? = nil

    // cancellable for top artists api
    @State private var getUserTopArtistsCancellable: AnyCancellable? = nil
    
    // cancellable for artist api
    @State private var getArtistsCancellable: AnyCancellable? = nil
    
    // cancellable for artist top tracks
    @State private var getArtistTopTracksCancellable: [AnyCancellable]? = []
    
    // store an alert
    @State private var alert: AlertItem? = nil
    
    // the mood to analyze
    private var selectedMood:SpotifyAnalysisViewModel.Moods?
    
    // the genre to generate the playlist from
    private var selectedGenre:NSString = "edm"

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
                    if userTopTracks.isEmpty {
                        if isLoadingPage {
                            HStack {
                                ProgressView()
                                    .padding()
                                Text("Loading Tracks")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                        else {
                            Text("No Recommended Tracks")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    else {
                        // show user top tracks
                        ForEach(
                            Array(recommendedTracks.enumerated()),
                            id: \.offset
                        ){item in
                            TrackView(track: item.element)
                        }
                        Spacer()
                        Button(action: { getUserTopArtists()
                        }){Text("Get Recommendations")}
                    }
                }
                Spacer()
                Button(action: {analyzedSongListVM.printNetworkCalls()}){
                    Text("Print network calls")
                }
            }
        }
        .onAppear{
            getTopTracks(trackLimit: 10)
        }
        .navigationTitle("User top tracks")
        .padding()
    }
}

extension SpotifyAnalysisScreen {
    
    func getRecommendations(genreIsSelected:Bool) {
        if !genreIsSelected {
            //
            // TODO: generate normalized genre
            //
        }
        //
        // TODO: check cache for genre mood seeds
        //
        if let cachedSeeds = analyzedSongListVM.retrieveCachedMoodSeeds(genre: selectedGenre, mood: selectedMood!){
            print("found cached mood seeds")
        }
        else {
            print("cached seeds not found")
            getRecommendationsWithMoodSeeds(trackLimit: 10, seedTracks: analyzedSongListVM.getAnalyzedMoodSeeds(bymood: selectedMood))
        }
        // there are no genre mood seeds cached, make network calls, and
        // retrieve the selected genre mood seed
        
    }
    
    /**
     * function returns user top tracks
     */
    func getTopTracks(trackLimit:Int?) {
        self.isLoadingPage = true
        self.userTopTracks = []
        var songIds:[String:String] = [:]
        
        self.getUserTopTracksCancellable = self.spotify.api
            .currentUserTopTracks(limit:trackLimit)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: self.getTopTracksCompletion(_:),
                receiveValue: {
                    response in self.userTopTracks = response.items
                    for song in response.items{
                        songIds[song.id!] = song.name
                    }
                    print(
                        "received first page with \(userTopTracks.count) items"
                    )
                    analyzedSongListVM.setSongIds(songIds: songIds)
                    analyzedSongListVM.networkCalls.spotify += 1
                    analyzedSongListVM.populateRecentlyPlayedSongAnalysis()
                }
            )
    }
    
    func getRecommendationsWithMoodSeeds(trackLimit:Int?, seedTracks:[String]){
        
        let trackIds = seedTracks.map { "spotify:track:" + $0 }
        let trackAttributes = TrackAttributes(seedTracks: trackIds)
        self.getRecommendationsCancellable = self.spotify.api
            .recommendations(trackAttributes, limit: trackLimit)
            .receive(on: RunLoop.main)
            .sink(
            receiveCompletion: self.getRecommendationsCompletion(_:),
            receiveValue: {
                response in
                self.recommendedTracks = response.tracks
                print(
                    "received first page with \(recommendedTracks.count) items"
                )
                analyzedSongListVM.networkCalls.spotify += 1
            }
        )
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
        var artists:[String] = []
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
                                    artists.append(artistId)
                                }
                            }
                        }
                    }
                }
                //
                // TODO: analyze artist top tracks
                // TODO: If mood and genre found, cache the track id
                //
                getArtistTopTracks(withIds: artists)
            }
        )
    }
    func getArtistTopTracks(withIds Ids:[String]){
        let myGroup = DispatchGroup()
        for Id in Ids {
            myGroup.enter()
            self.getArtistTopTracksCancellable?.append(  self.spotify.api.artistTopTracks(artistURI(URI: Id), country: "US")
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: self.getArtistTopTracksCompletion(_:),
                      receiveValue: { response in
                    for item in response {
                        print("Found track \(item.name)")
                    }
                    myGroup.leave()
                }))
        }
        myGroup.notify(queue: .main) {
            print("Finished all requests.")
        }
    }
}

extension SpotifyAnalysisScreen {
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
        self.isLoadingPage = false
    }
    
    func getTopTracksCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            let title = "Couldn't retrieve user top tracks"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
        self.isLoadingPage = false
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