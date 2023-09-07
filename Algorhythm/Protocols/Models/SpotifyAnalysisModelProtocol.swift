//
//  SpotifyAnalysisModelProtocol.swift
//  Algorhythm
//
//  Created by Jack Belding on 9/6/23.
//

import Foundation

protocol SpotifyAnalysisModelProtocol {
    var id: String { get }
    var genreTags: [AudioAnalysisV6GenreTags]? { get }
    var moodTags: [AudioAnalysisV6MoodTags]? { get }
}
