//
//  RootViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/20/23.
//

import Foundation
import Combine
import SpotifyWebAPI

// MARK: - RootViewModel
class RootViewModel: ObservableObject {
    // MARK: - Variables
    internal var spotifyRepository: SpotifyRepositoryProtocol
    @Published var alert: AlertItem? = nil
    
    // MARK: - Initializer
    init(spotify: Spotify) {
        self.spotifyRepository = SpotifyRepository(spotify: spotify)
    }
    
    // MARK: - Handlers
    func handleAuthRedirectURL(_ url: URL) {
        spotifyRepository.handleAuthRedirectURL(url, completionHandler: handleAuthCompletion(completion:)) { [weak self] alertItem in
            self?.alert = alertItem
        }
    }
    
    // MARK: - Private Functions
    internal func handleAuthCompletion(completion: Subscribers.Completion<Error>) {
        
        if case .failure(let error) = completion {
            print("couldn't retrieve access and refresh tokens:\n\(error)")
            let alertTitle: String
            let alertMessage: String
            if let authError = error as? SpotifyAuthorizationError,
               authError.accessWasDenied {
                alertTitle = "You Denied The Authorization Request :("
                alertMessage = ""
            } else {
                alertTitle = "Couldn't Authorization With Your Account"
                alertMessage = error.localizedDescription
            }
            self.alert = AlertItem(
                title: alertTitle, message: alertMessage
            )
        }
    }
}
