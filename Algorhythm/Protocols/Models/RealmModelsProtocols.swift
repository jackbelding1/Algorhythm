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
    // The `count` property is expected to already exist in any conforming type,
    // such as Swift's Array or Realm's List. Therefore, no explicit implementation
    // is required in the conforming types.
    var count: Int { get }
    mutating func removeAll()
}
