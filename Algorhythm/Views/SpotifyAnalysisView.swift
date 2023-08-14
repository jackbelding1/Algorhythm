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
        case inProgress
        case waitingRequest
        case success
        case failure
    }
    @State private var playlistCreationState:PlaylistState = .waitingRequest
    
    // spotify object
    @EnvironmentObject var spotify: Spotify
    @EnvironmentObject var appState: AppState
    
    @StateObject private var spotifyAnalysisViewModel:SpotifyAnalysisViewModel
    // the playlist name to print. This will likely become an object
    @State private var playlist:String = ""
    
    // display loading page
    @State private var isLoadingPage = false
    
    @State private var createPlaylistCancellable: AnyCancellable? = nil
    
    @State private var addTracksCancellable: AnyCancellable? = nil
    
    // The text for the link to spotify
    @State private var spotifyButtonText = ""
    
    // store an alert
    @State private var alert: AlertItem? = nil
    
    // the offset of user artists to analyze
    @State private var artistOffset:Int = 0
    
    // the counter for the amount of retrys we make
    @State private var retryCounter:Int = 1
    
    // the current time range
    @State private var currentTimeRange:TimeRange = TimeRange.shortTerm
    
    // the created playlist uri
    @State private var createdPlaylistId:String = ""
    
    // initializer
    init(mood:String?, _ playlistOptionsVM:PlaylistOptionsViewModel,
         withViewModel spotifyAnalysisViewModel:SpotifyAnalysisViewModel) {
        _spotifyAnalysisViewModel = StateObject(wrappedValue: spotifyAnalysisViewModel)
        playlistOptions = playlistOptionsVM
    }
    // preview initializer
    fileprivate init(recommendedTracks: [Track], _ playlistOptionsVM:PlaylistOptionsViewModel,
                     withViewModel spotifyAnalysisViewModel:SpotifyAnalysisViewModel) {
        _spotifyAnalysisViewModel = StateObject(wrappedValue: spotifyAnalysisViewModel)
        playlistOptions = playlistOptionsVM
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
    
    private func waitingRequestView() -> some View {
        VStack {
            Text("Name your playlist!")
                .font(.title)
                .padding()
            TextField(text: $playlist, prompt: Text("Type Here")){}
                .font(.largeTitle)
                .padding(EdgeInsets(top: 80, leading: 55, bottom: 1, trailing: 55))
                .disableAutocorrection(true)
            Divider()
            Button(action: {
                spotifyAnalysisViewModel.createPlaylist(
                    withPlaylistName: $playlist.wrappedValue)
                playlistCreationState = .inProgress
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
        }
    }
    
    private var openSpotifyButton: some View {
        Button(action: openSpotify) {
            HStack {
                Image(spotifyLogo)
                    .interpolation(.high)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                if UIApplication.shared.canOpenURL(URL(string: "https://open.spotify.com/")!) {
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
    }
    
    private func inProgressView() -> some View {
        VStack {
            ProgressView()
                .padding()
            Text("Creating playlist...")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
    
    private func successView() -> some View {
        VStack {
            Spacer()
            Group {
                Text("✅")
                    .font(.largeTitle)
                Text("Success!")
                    .font(.largeTitle)
            }
            Divider()
            Spacer()
            openSpotifyButton
            returnHomeButton
        }
    }
    
    private func failureView() -> some View {
        VStack {
            Spacer()
            Group {
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
    
    var body: some View {
        VStack {
            if spotifyAnalysisViewModel.recommendedTracksEmpty() &&
                spotifyAnalysisViewModel.recommendationSeedIds.isEmpty && (spotifyAnalysisViewModel.playlistCreationState != .failure) {
                HStack {
                    ProgressView()
                        .padding()
                    Text("Loading Tracks")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            } else {
                switch (spotifyAnalysisViewModel.playlistCreationState) {
                case .waitingRequest:
                    waitingRequestView()
                case .inProgress:
                    inProgressView()
                case .success:
                    successView()
                case .failure:
                    failureView()
                }
            }
            Spacer()
        }
        .onAppear{
            getSeeds()
        }
        .padding()
        .navigationBarHidden(playlistCreationState == PlaylistState.success
                             || playlistCreationState == PlaylistState.failure)
    }
    
    private func openSpotify() {
        let spotifyUrl = URL(string: "https://open.spotify.com/playlist/\(createdPlaylistId)")!
        if UIApplication.shared.canOpenURL(spotifyUrl) {
            UIApplication.shared.open(spotifyUrl) // open the Spotify app
        } else {
            if let appStoreURL = URL(string: "https://itunes.apple.com/us/app/apple-store/id324684580") {
                UIApplication.shared.open(appStoreURL) // download spotify from the appstore
            }
        }
    }
}

extension SpotifyAnalysisScreen {
    
    func getSeeds() {
        
        // Don't try to load any playlists if we're in preview mode.
        if ProcessInfo.processInfo.isPreviewing { return }

        if !spotifyAnalysisViewModel.loadMoodFromDatabase(){
            spotifyAnalysisViewModel.getUserTopArtists(
                timeRange: currentTimeRange,
                offset: artistOffset,
                limit: 50
            ) // download mood seed from network
        }
        else {
            spotifyAnalysisViewModel.getRecommendedTracks()
        }
    }
    
    // DEPRICATED
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
                    self.spotifyAnalysisViewModel.writePlaylistId(response.id)
                    if !playlistURI.isEmpty {
                        let trackURIs:[String] = spotifyAnalysisViewModel.recommendedTracks.map {"spotify:track:\($0.id!)" }
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
        if spotifyAnalysisViewModel.networkCalls.cyanite > 200 {
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
        spotifyAnalysisViewModel.getUserTopArtists(
            timeRange: currentTimeRange,
            offset: artistOffset,
            limit: 50
        )
    }
}

extension SpotifyAnalysisScreen {
    func createPlaylistCompletion(
        _ completion: Subscribers.Completion<Error>
    ) {
        if case .failure(let error) = completion {
            self.playlistCreationState = .failure
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
            self.playlistCreationState = .failure
            let title = "Couldn't add items"
            print("\(title): \(error)")
            self.alert = AlertItem(
                title: title,
                message: error.localizedDescription
            )
        }
    }
}

//struct SpotifyAnalysisScreen_Previews: PreviewProvider {
//
//    static let tracks: [Track] = [
//        .because, .comeTogether, .faces, .illWind,
//        .odeToViceroy, .reckoner, .theEnd, .time
//    ]
//
//    static var previews: some View {
//        ForEach([tracks], id: \.self) { tracks in
//            NavigationView {
//                SpotifyAnalysisScreen(recommendedTracks: tracks, PlaylistOptionsViewModel())
//                    .listStyle(PlainListStyle())
//            }
//        }
//    }
//}
