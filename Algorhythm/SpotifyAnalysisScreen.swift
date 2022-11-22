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

    // cancellable for top items api
    @State private var getUserTopTracksCancellable: AnyCancellable? = nil
    
    // cancellable for track recommendation api
    @State private var getRecommendationsCancellable: AnyCancellable? = nil

    // store an alert
    @State private var alert: AlertItem? = nil
    
    // the mood to analyze
    private var selectedMood:SpotifyAnalysisViewModel.Moods?

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
                        Button(action: {
                            getRecommendationsWithMoodSeeds(trackLimit: 10, seedTracks: analyzedSongListVM.getAnalyzedMoodSeeds(bymood: selectedMood))
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
                })
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
