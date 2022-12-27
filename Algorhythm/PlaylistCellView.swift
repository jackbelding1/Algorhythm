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
                    Text("\(playlist.name)")
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
        let spotifyUrl = URL(string: "https://open.spotify.com/playlist/\(playlist.id)")!
        if UIApplication.shared.canOpenURL(spotifyUrl) {
            UIApplication.shared.open(spotifyUrl) // open the spotify app
        }
        else {
            // redirect user to app store to install spotfiy
            print("Spotify app not found!!!")
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
