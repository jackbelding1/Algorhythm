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

    // cancellable for api
    @State private var getUserTopTracksCancellable: AnyCancellable? = nil

    // store an alert
    @State private var alert: AlertItem? = nil

    
    // initializer
    init() {
        self._userTopTracks = State(initialValue: [])
    }
    // preview initializer
    fileprivate init(topTracks: [Track]) {
        self._userTopTracks = State(initialValue: topTracks)
    }
    
    var body: some View {
        NavigationView{
            VStack{
                List(analyzedSongListVM.analyzedSongs, id: \.id){song in
                    Text(song.id)
                }
                Spacer()
                Button(action: {analyzedSongListVM.printNetworkCalls()}){
                    Text("Print network calls")
                }
            }

        }
        .onAppear(perform: {
            getTopTracks(trackLimit: 25)
//            analyzedSongListVM.populateRecentlyPlayedSongAnalysis()
        })
        .navigationTitle("Recently played songs")
        .padding()
    }
    /**
     * function returns user top tracks
     */
    func getTopTracks(trackLimit:Int?) {
        self.isLoadingPage = true
        self.userTopTracks = []
        
        self.getUserTopTracksCancellable = self.spotify.api
            .currentUserTopTracks(limit:trackLimit)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: self.getTopTracksCompletion(_:),
                receiveValue: {
                    response in self.userTopTracks = response.items
                    print(
                        "received first page with \(userTopTracks.count) items"
                    )
                    analyzedSongListVM.networkCalls.spotify += 1
                })
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
                SpotifyAnalysisScreen(topTracks: tracks)
                    .listStyle(PlainListStyle())
            }
        }
        .environmentObject(Spotify())
    }
}
