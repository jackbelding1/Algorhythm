//
//  PlaylistOptionsViewModel.swift
//  Algorhythm
//
//  Created by Jack Belding on 1/18/23.
//

import Foundation
import Combine

struct genrePreference {
    let title:String
    let key:String
    var value:Bool
}

class PlaylistOptionsViewModel: ObservableObject {
    
    @Published var shouldSavePreferences: Bool = false
    
    //
    // TODO: add dependency that retrieves the list of genrePreferences to be displayed
    //
    private let genres = [
        ("edm", "EDM"),
        ("country", "Country"),
        ("rap", "Hip-Hop/Rap")
    ]
    
    private var initialPreferenceState: [genrePreference] = []

    @Published var genrePreferencesCollection: [genrePreference] = []

    
    public init() {
        // create collection of genre preference options
        for genre in genres {
            let preference = genrePreference(title: genre.1, key: genre.0, value: false)
            genrePreferencesCollection.append(preference)
        }
        shouldSavePreferences = UserDefaults.standard.bool(forKey: "shouldSavePreferences")
    }
    

    private let algoDBManager = AlgoDataManager()
    
    func savePlaylistOptions() {

    }
    
    func savePreferenceState() {
        initialPreferenceState = genrePreferencesCollection
    }
    
    // called when user exits the view and does not tap update
    func restorePreferences() {
        genrePreferencesCollection = initialPreferenceState
    }
    
    func handleTapUpdate() {
        if shouldSavePreferences {
            // write data from copy into real VM
            // write data into realm db
//            algoDBManager.savePlaylistOptions(<#T##preferences: [String : Bool]##[String : Bool]#>)
        }
    }
    
    func updateSavePreferences(isMarked: Bool) {
        shouldSavePreferences = !isMarked
        UserDefaults.standard.set(shouldSavePreferences, forKey: "shouldSavePreferences")
    }
    
    func updateGenreSelection(id: String, isMarked: Bool) {
        for index in 0..<genrePreferencesCollection.count {
            if genrePreferencesCollection[index].key == id {
                // Update the value property for the matched element
                genrePreferencesCollection[index].value = !isMarked
                break
            }
        }
    }

    func clearGenreSelections() {
        for index in 0..<genrePreferencesCollection.count {
            genrePreferencesCollection[index].value = false
        }
    }
}
