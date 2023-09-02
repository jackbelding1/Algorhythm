//
//  RealmModels+Extensions.swift
//  AlgorhythmTests
//
//  Created by Jack Belding on 8/31/23.
//

import Foundation
import RealmSwift

extension Array: AnyPlaylistOptionList where Element == PlaylistOption {
    mutating func removeAll() {
        self = []
    }
    
    mutating func add(_ option: PlaylistOption) {
        self.append(option)
    }
    
    func remove(_ option: PlaylistOption) {
        // your removal logic here
    }
    func first() -> PlaylistOption? { return self.first }
}

extension List: AnyPlaylistOptionList where Element == PlaylistOption {
    func add(_ option: PlaylistOption) {
        self.append(option)
    }

    func remove(_ option: PlaylistOption) {
        // your removal logic here
    }
    func first() -> PlaylistOption? { return self.first }
}

