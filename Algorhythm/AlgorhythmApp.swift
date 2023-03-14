//
//  AlgorhythmApp.swift
//  Algorhythm
//
//  Created by Jack Belding on 11/2/22.
//

import SwiftUI
import Combine
import SpotifyWebAPI

@main
struct AlgorhythmApp: App {
    @ObservedObject var appState = AppState()
    @StateObject var spotify = Spotify()
    @StateObject var sheetManager = SheetManager()

    init() {
        SpotifyAPILogHandler.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(spotify)
                .environmentObject(appState)
            
        }
    }
}
