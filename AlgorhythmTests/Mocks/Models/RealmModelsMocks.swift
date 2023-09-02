//
//  RealmModelsMocks.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 8/31/23.
//

import Foundation
@testable import Algorhythm

final class MockPlaylistOptionsList: PlaylistOptionsListProtocol {
    private var playlistOptionsArray: [PlaylistOption] = [] {
        didSet {
            if !(playlistOptionsArray.elementsEqual(playlistOptions as! [PlaylistOption])) {
                self.playlistOptions = playlistOptionsArray
            }
        }
    }

    var playlistOptions: AnyPlaylistOptionList {
        didSet {
            if let newOptionsArray = playlistOptions as? [PlaylistOption],
               !newOptionsArray.elementsEqual(playlistOptionsArray) {
                self.playlistOptionsArray = newOptionsArray
            }
        }
    }
    var test: Int = 1
    
    init() {
        self.playlistOptions = playlistOptionsArray
    }
}
