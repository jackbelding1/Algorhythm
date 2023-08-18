//
//  PlaylistsListView.swift
//  Algorhythm
//
//  Created by Jack Belding on 12/23/22.
//

import SwiftUI
import Combine
import SpotifyWebAPI

// MARK: - URI Definition
struct playlistURI: SpotifyURIConvertible {
    var uri:String
    
    init(URI playlistUri:String){
        self.uri = "spotify:playlist:\(playlistUri)"
    }
}

// MARK: - Playlists List View
struct PlaylistsListView: View {
    // MARK: - Variables
    @EnvironmentObject var spotify: Spotify
    @StateObject var viewModel: SpotifyPlaylistsListViewModel
    
    // MARK: - Initialization
    init(spotify: Spotify) {
        _viewModel = StateObject(wrappedValue: SpotifyPlaylistsListViewModel(spotify: spotify))
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            displayPlaylistsOrMessage()
        }
        .navigationBarItems(trailing: refreshButton)
        .alert(item: $viewModel.alert, content: createAlert)
        .onAppear(perform: retrievePlaylists)
    }

    // MARK: - View Helpers
    private func displayPlaylistsOrMessage() -> some View {
        if viewModel.playlists.isEmpty {
            return AnyView(loadingOrEmptyView())
        } else {
            return AnyView(playlistsView())
        }
    }

    private func loadingOrEmptyView() -> some View {
        Group {
            if viewModel.isLoadingPlaylists {
                loadingView()
            } else if viewModel.couldntLoadPlaylists {
                Text("Couldn't Load Playlists")
                    .font(.title)
                    .foregroundColor(.secondary)
            } else {
                Text("No Playlists Found")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func loadingView() -> some View {
        HStack {
            ProgressView()
                .padding()
            Text("Loading Playlists")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }

    private func playlistsView() -> some View {
        List {
            ForEach(viewModel.playlists, id: \.uri) { playlist in
                PlaylistCellView(spotify: spotify, playlist: playlist)
            }
            .onDelete(perform: delete)
        }
        .listStyle(PlainListStyle())
        .accessibility(identifier: "Playlists List View")
        .padding(.top, 20)
    }

    // MARK: - Actions
    private func createAlert(for alert: AlertItem) -> Alert {
        Alert(title: alert.title, message: alert.message)
    }
    
    private func delete(at offsets: IndexSet) {
        viewModel.delete(at: offsets)
    }
    
    private var refreshButton: some View {
        Button(action: retrievePlaylists) {
            Image(systemName: "arrow.clockwise")
                .font(.title)
                .scaleEffect(0.8)
                .frame(height: 30)

        }
        .disabled(viewModel.isLoadingPlaylists)
    }

    private func retrievePlaylists() {
        viewModel.retrievePlaylists()
    }
}
