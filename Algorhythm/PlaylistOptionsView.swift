//
//  PlayListOptionsView.swift
//  Algorhythm
//
//  Created by Jack Belding on 1/18/23.
//

import SwiftUI

struct PlaylistOptionsView: View {
    // The view model
    @State private var playlistOptions:PlaylistOptionsViewModel
    // initializer
    init(_ viewModel:PlaylistOptionsViewModel, shouldLoadOptions loadOptions:Bool) {
        playlistOptions = viewModel
        if loadOptions {
            playlistOptions.loadPlaylistOptions()
        }
    }
    
    var body: some View {
        VStack{
            CheckboxField(id: "edm",
                          label: "EDM",
                          size: 18,
                          textSize: 18,
                          callback: checkboxSelected,
                          isMarked: playlistOptions.getPreference(withPreference: "edm"))
            CheckboxField(id: "country",
                          label: "Country",
                          size: 18,
                          textSize: 18,
                          callback: checkboxSelected,
                          isMarked: playlistOptions.getPreference(withPreference: "country"))
            CheckboxField(id: "rap",
                          label: "Hip-Hop/Rap",
                          size: 18,
                          textSize: 18,
                          callback: checkboxSelected,
                          isMarked: playlistOptions.getPreference(withPreference: "rap"))
        }
    }
    // checkbox selected call back
    func checkboxSelected(id: String, isMarked: Bool) {
        // save is marked to the view model
        playlistOptions.editGenrePreference(forGenre: id, toValue: isMarked)
    }
}

struct PlaylistOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistOptionsView(PlaylistOptionsViewModel(), shouldLoadOptions: false)
    }
}
