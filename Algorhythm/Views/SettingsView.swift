//
//  SettingsView.swift
//  Algorhythm
//
//  Created by Jack Belding on 12/27/22.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var spotify: Spotify
    
    var body: some View {
        logoutButton
    }
    
    /// Removes the authorization information for the user.
    var logoutButton: some View {
        // Calling `spotify.api.authorizationManager.deauthorize` will cause
        // `SpotifyAPI.authorizationManagerDidDeauthorize` to emit a signal,
        // which will cause `Spotify.authorizationManagerDidDeauthorize()` to be
        // called.
        Button(action: spotify.api.authorizationManager.deauthorize, label: {
            Text("Logout")
                .foregroundColor(.white)
                .padding(7)
                .background(
                    Color(red: 0.392, green: 0.720, blue: 0.197)
                )
                .cornerRadius(10)
                .shadow(radius: 3)
            
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
