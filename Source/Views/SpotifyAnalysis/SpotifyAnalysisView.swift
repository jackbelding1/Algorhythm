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
    // MARK: - Constants
    private let enterPlaylistNamePadding = EdgeInsets(top: 80, leading: 55, bottom: 1, trailing: 55)
    
    enum PlaylistState {
        case inProgress
        case waitingRequest
        case success
        case failure
    }
    // MARK: - Variables
    @StateObject private var spotifyAnalysisViewModel: SpotifyAnalysisViewModel
    
    private var userPlaylistOptions: NewPlaylistViewModel
    
    /// singleton spotify api object
    @EnvironmentObject var spotify: Spotify
    @EnvironmentObject var appState: AppState
    

    @State private var playListName: String = ""
    
    @Environment(\.colorScheme) var colorScheme
    var spotifyLogo: ImageName {
        colorScheme == .dark ? .spotifyLogoWhite
        : .spotifyLogoBlack
    }
        
    // MARK: - Initializers
    init(_ playlistOptionsVM: NewPlaylistViewModel,
         withViewModel spotifyAnalysisViewModel: SpotifyAnalysisViewModel) {
        _spotifyAnalysisViewModel = StateObject(wrappedValue: spotifyAnalysisViewModel)
        userPlaylistOptions = playlistOptionsVM
    }
    /// preview initializer
    fileprivate init(recommendedTracks: [Track], _ playlistOptionsVM: NewPlaylistViewModel,
                     withViewModel spotifyAnalysisViewModel: SpotifyAnalysisViewModel) {
        _spotifyAnalysisViewModel = StateObject(wrappedValue: spotifyAnalysisViewModel)
        userPlaylistOptions = playlistOptionsVM
    }
    // MARK: - Body
    var body: some View {
        VStack {
            switch (spotifyAnalysisViewModel.playlistCreationState) {
            case .inititializationFailure:
                failureView(withCaption: "Failed to initialize")
            case .enterPlaylistName:
                enterPlaylistNameView()
            case .inProgress:
                inProgressView()
            case .success:
                successView()
            case .failure:
                failureView(withCaption: "Failed to create playlist")
            }
            Spacer()
        }
        .padding()
        .navigationBarHidden(
            spotifyAnalysisViewModel.playlistCreationState == .success ||
            spotifyAnalysisViewModel.playlistCreationState == .failure)
        .onAppear(perform: spotifyAnalysisViewModel.generateRecommendations)
    }
   
    // MARK: - Subviews for Different States
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
    
    private func failureView(withCaption caption:String) -> some View {
        VStack {
            Spacer()
            Group {
                Text("❌")
                    .font(.largeTitle)
                Text(caption)
                    .font(.largeTitle)
            }
            Divider()
            Spacer()
            returnHomeButton
        }
    }
    
    private func enterPlaylistNameView() -> some View {
        VStack {
            Text("Name your playlist!")
                .font(.title)
                .padding()
            TextField(text: $playListName, prompt: Text("Type Here")){}
                .font(.largeTitle)
                .padding(enterPlaylistNamePadding)
                .disableAutocorrection(true)
            Divider()
            createPlaylistButton
        }
    }
    
    // MARK: - Buttons
    private var returnHomeButton: some View {
        CustomButton(action: { appState.rootViewId = UUID() }) {
            AnyView(
                Text("Return Home")
                    .padding(EdgeInsets(top: 30, leading: 50, bottom: 30, trailing: 50))
                    .font(.title2)
                    .lineLimit(1)
            )
        }
    }
    
    var createPlaylistButton: some View {
        CustomButton(action: {
            spotifyAnalysisViewModel.createPlaylist(
                withPlaylistName: $playListName.wrappedValue)
            spotifyAnalysisViewModel.playlistCreationState = .inProgress
        }) {
            AnyView(
                Text("Create")
                    .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                    .lineLimit(1)
            )
        }
        .disabled($playListName.wrappedValue == "")
        .padding(EdgeInsets(top: 50, leading: 100, bottom: 1, trailing: 100))
    }
    
    private var openSpotifyButton: some View {
        CustomButton(action: spotifyAnalysisViewModel.openSpotify) {
            AnyView(
                HStack {
                    Image(spotifyLogo)
                        .interpolation(.high)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                    if UIApplication.shared.canOpenURL(URL(string:"spotify:open")!) {
                        Text("Open Spotify")
                            .font(.title2)
                            .padding()
                    } else {
                        Text("Get Spotify Free")
                            .font(.system(size: 17))
                            .padding()
                    }
                }
                .padding()
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
