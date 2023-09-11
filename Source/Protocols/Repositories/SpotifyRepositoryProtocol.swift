//
//  SpotifyRepositoryProtocol.swift
//  Algorhythm
//
//  Created by Jack Belding on 9/2/23.
//

import Foundation
import SpotifyWebAPI
import SwiftUI
import Combine

// MARK: - SpotifyRepositoryProtocol
protocol SpotifyRepositoryProtocol {
    
    // MARK: - Shared properties
    func openPlaylistURL(playlistId: String) -> URL?
    
    // MARK: - SpotifyAnalysisRepository
    func getUserTopArtists(timeRange: TimeRange, offset: Int, limit: Int, completion: @escaping (Result<[Artist], Error>) -> Void)
    func getRecommendations(trackURIs: [String], completion: @escaping (Result<[Track], Error>) -> Void)
    func getArtistTopTracks(artistId: String, completion: @escaping (Result<[Track], Error>) -> Void)
    
    // MARK: - SpotifyPlaylistsRepository
    func analyzeSpotifyTrack(by id: String, completion: @escaping (Result<SpotifyTrackQueryQuery.Data.SpotifyTrack, Error>) -> Void)
    func createPlaylist(playlistDetails: PlaylistDetails, completion: @escaping (Result<Playlist<PlaylistItems>, Error>) -> Void)
    func addToPlaylist(playlistURI: String, uris: [String], completion: @escaping (Result<Void, Error>) -> Void)
    func retrievePlaylists(idsToLoad: [String], completion: @escaping (Result<[Playlist<PlaylistItemsReference>], Error>) -> Void)
    func deletePlaylist(withId Id: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    // MARK: - SpotifyPlaylistCell
    func loadImage(forPlaylist playlist: Playlist<PlaylistItemsReference>, completion: @escaping (Image?) -> Void)
    
    // MARK: - RootViewModel
    func handleAuthRedirectURL(_ url: URL, completionHandler: @escaping (Subscribers.Completion<Error>) -> Void, showAlert: @escaping (AlertItem) -> Void)
}
