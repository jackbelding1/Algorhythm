//
//  RealmModelsProtocols.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/31/23.
//

import Foundation

protocol PlaylistOptionsListProtocol {
    var playlistOptions: AnyPlaylistOptionList { get set }
    var test: Int { get set }
}

protocol AnyPlaylistOptionList {
    mutating func add(_ option: PlaylistOption)
    func remove(_ option: PlaylistOption)
    func first() -> PlaylistOption?
}
