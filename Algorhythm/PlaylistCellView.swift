//
//  PlaylistCellView.swift
//  Algorhythm
//
//  Created by Jack Belding on 12/23/22.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistCellView: View {
    
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    var spotifyLogo: ImageName {
        colorScheme == .dark ? .spotifyLogoWhite
                : .spotifyLogoBlack
    }
    
    let playlist: Playlist<PlaylistItemsReference>

    /// The cover image for the playlist.
    @State private var image = Image(.spotifyAlbumPlaceholder)

    @State private var didRequestImage = false
    
    @State private var alert: AlertItem? = nil
    
    // MARK: Cancellables
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var openPlaylistCancellable: AnyCancellable? = nil
    
    init(spotify: Spotify, playlist: Playlist<PlaylistItemsReference>) {
        self.spotify = spotify
        self.playlist = playlist
    }
    
    var body: some View {
        HStack {
            Button(action: openPlaylist, label: {
                HStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading){
                        Text("\(playlist.name)")
                        HStack {
                            Image(spotifyLogo)
                                .interpolation(.high)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 10)
                            // if app is installed
                            if UIApplication.shared.canOpenURL(URL(string: "spotify://")!) {
                                Text("Open Spotify")
                                    .font(.system(size: 10))
                            } else {
                                Text("Get Spotify Free")
                            }
                        }
                    }
                    Spacer()
                }
                // Ensure the hit box extends across the entire width of the frame.
                // See https://bit.ly/2HqNk4S
                .contentShape(Rectangle())
            })
            .buttonStyle(PlainButtonStyle())
            .alert(item: $alert) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .onAppear(perform: loadImage)
        }
    }
    
    /// Loads the image for the playlist.
    func loadImage() {
        
        // Return early if the image has already been requested. We can't just
        // check if `self.image == nil` because the image might have already
        // been requested, but not loaded yet.
        if self.didRequestImage {
            // print("already requested image for '\(playlist.name)'")
            return
        }
        self.didRequestImage = true
        
        guard let spotifyImage = playlist.images.largest else {
            // print("no image found for '\(playlist.name)'")
            return
        }

        // print("loading image for '\(playlist.name)'")
        
        // Note that a `Set<AnyCancellable>` is NOT being used so that each time
        // a request to load the image is made, the previous cancellable
        // assigned to `loadImageCancellable` is deallocated, which cancels the
        // publisher.
        self.loadImageCancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    // print("received image for '\(playlist.name)'")
                    self.image = image
                }
            )
    }
    
    func openPlaylist() {
        let spotifyUrl = URL(string: "spotify://playlist/\(playlist.id)")!
        if UIApplication.shared.canOpenURL(spotifyUrl) {
            UIApplication.shared.open(spotifyUrl) // open the spotify app
        }
        else {
            if let appStoreURL = URL(string: "https://itunes.apple.com/us/app/apple-store/id324684580") {
             UIApplication.shared.open(appStoreURL)
            }
        }
    }
    
}

struct PlaylistCellView_Previews: PreviewProvider {

    static let spotify = Spotify()
    
    static var previews: some View {
        List {
            PlaylistCellView(spotify: spotify, playlist: .thisIsMildHighClub)
            PlaylistCellView(spotify: spotify, playlist: .thisIsRadiohead)
            PlaylistCellView(spotify: spotify, playlist: .modernPsychedelia)
            PlaylistCellView(spotify: spotify, playlist: .rockClassics)
            PlaylistCellView(spotify: spotify, playlist: .menITrust)
        }
        .environmentObject(spotify)
    }
    
}
