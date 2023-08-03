//
//  PlaylistOptionsViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 1/18/23.
//

import Foundation

class PlaylistOptionsViewModel: ObservableObject {
    // the realm database manager
    private let algoDBManager = AlgoDataManager()
    
    // save function to be called from view
    func savePlaylistOptions(){
        algoDBManager.savePlaylistOptions(preferredGenres)
    }
    
    // load function to be called from view
    func loadPlaylistOptions() {
        guard let playlistOptions = algoDBManager.loadPlaylistOptions() else {
            print("Error! Playlist options not found")
            return
        }
        for playlistOption in playlistOptions {
            preferredGenres[playlistOption.genre] = playlistOption.value
        }
    }
    
    // function to get a random genre from the dictionary of preferred genres
    func getRandomGenre() -> String {
        var genres:[String] = []
        for (genre, value) in preferredGenres {
            if value {
                genres.append(genre)
            }
        }
        if genres.isEmpty {
            //
            // TODO: Return random genre
            //
            return "edm"
        }
        let random = Int.random(in: 0..<genres.count)
        return genres[random]
        
    }
    
    // reset the playlist options to default state
    func defaultPlaylistOptions() {
        algoDBManager.restorePlaylistOptionDefaults()
    }
    
    // getter for genre preference dictionary
    fileprivate func getGenrePreferences() -> [String:Bool] {
        return self.preferredGenres
    }
    // dictionary to store the checkbox values of the user genre preferences
    private var preferredGenres:[String:Bool] = [:]
    // func to add value to dictionary preferredGenres
    func editGenrePreference(forGenre genre:String, toValue val:Bool) {
        preferredGenres[genre] = val
    }
    // func to retrieve genre preference value
    func getPreference(withPreference preference:String) -> Bool {
        if let val = preferredGenres[preference] {
            return val
        }
        else {
            print("\n\nerror! value not found with key \(preference)\n\n")
            return false
        }
    }
    
    func makeCopy(from copy:PlaylistOptionsViewModel) {
        self.preferredGenres = copy.getGenrePreferences()
    }
}
