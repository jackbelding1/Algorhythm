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
    
    @ObservedObject var viewModel: PlaylistCellViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var spotifyLogo: ImageName {
        colorScheme == .dark ? .spotifyLogoWhite : .spotifyLogoBlack
    }
    
    @State private var playlistImage = Image(.spotifyAlbumPlaceholder)
    
    init(spotify: Spotify, playlist: Playlist<PlaylistItemsReference>) {
        self.viewModel = PlaylistCellViewModel(
            spotify: spotify,
            playlist: playlist
        )
    }
    
    var body: some View {
        HStack {
            Button(action: {
                if let url = viewModel.openPlaylist() {
                    UIApplication.shared.open(url)
                }
            }, label: {
                HStack {
                    playlistImage
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 70, height: 70)
                       .padding(.trailing, 5)
                    VStack(alignment: .leading){
                        Text("\(viewModel.getPlaylistName())")
                        HStack {
                            Image(spotifyLogo)
                                .interpolation(.high)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 10)
                            if UIApplication.shared.canOpenURL(URL(string: "spotify:open")!) {
                                Text("Open Spotify")
                                    .font(.system(size: 10))
                            } else {
                                Text("Get Spotify Free")
                            }
                        }
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            })
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear(perform: loadImage)
    }
    
    func loadImage() {
        viewModel.loadImage() { loadedImage in
            guard let data = loadedImage else {
                    self.playlistImage = Image(.spotifyAlbumPlaceholder)
                    return
                }
                self.playlistImage = data
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
    }
    
}
