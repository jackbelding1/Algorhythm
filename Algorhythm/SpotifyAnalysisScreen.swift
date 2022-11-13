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
                        ForEach(
                            Array(userTopTracks.enumerated()),
                            id: \.offset
                        ){item in
                            TrackView(track: item.element)
                                // Each track in the list will be loaded lazily. We
                                // take advantage of this feature in order to detect
                                // when the user has scrolled to *near* the bottom
                                // of the list based on the offset of this item.
                            }
                    }
                }
                List(analyzedSongListVM.analyzedSongs, id: \.id ){song in
                    if let energy = song.energetic {
                        Text("\(song.name) | \(energy)")
                    }
                    else {
                        Text("n/a")
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
