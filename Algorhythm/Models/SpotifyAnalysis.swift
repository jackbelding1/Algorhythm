//
//  SpotifyAnalysis.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/9/23.
//

import Foundation

class SpotifyAnalysisModel {
    
    let analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack
    
    var id: String {
        analyzedSpotifyTrack.asSpotifyTrack!.id
    }
    // the object for the top 3 moods of a track
    var maxMoods:TrackMoods = TrackMoods()
    
    init(analyzedSpotifyTrack: SpotifyTrackQueryQuery.Data.SpotifyTrack) {
        self.analyzedSpotifyTrack = analyzedSpotifyTrack
        getMaxValue()
        print(id)
    }
    
}

// the key value pair of mood to score value
struct moodElement {
    public var mood:SpotifyAnalysisModel.Moods
    public var val:Double = 0
    
    init(mood: SpotifyAnalysisModel.Moods, val: Double) {
        self.mood = mood
        self.val = val
    }
}

class TrackMoods {
    // the amount of moods to keep track of
    private var maxMoodLimit = 3

    private var maxMoods:[moodElement] = []
    
    func isInList(_ mood:SpotifyAnalysisModel.Moods) -> Bool{
        for el in maxMoods {
            if el.mood == mood {
                return true
            }
        }
        return false
    }
    
    func updateMaxMoods(_ listEl:moodElement) -> Double {
        // variable to return
        var max = 0.0
        // add the list item
        maxMoods.append(listEl)
        // set the max and clean up the list
        if maxMoods.count >= maxMoodLimit {
            max = maxMoods[maxMoodLimit - 1].val
            if maxMoods.count > maxMoodLimit {
                maxMoods = maxMoods.sorted { $0.val > $1.val }
                maxMoods.removeLast()
            }
        }
        return max
    }
}

extension SpotifyAnalysisModel {
    
    // the genres associated with the track
    var genreTags:[AudioAnalysisV6GenreTags]? {
        analyzedSpotifyTrack.asSpotifyTrack?.audioAnalysisV6.asAudioAnalysisV6Finished?.result.genreTags
    }
    
    var moodTags:[AudioAnalysisV6MoodTags]? {
        analyzedSpotifyTrack.asSpotifyTrack?.audioAnalysisV6.asAudioAnalysisV6Finished?.result.moodTags
    }
    
    var energetic:Double? {
        analyzedSpotifyTrack.asSpotifyTrack?.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.energetic
    }

    var dark:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.dark
    }

    var happy:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.happy
    }

    var romantic:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.romantic
    }
    
    var calm:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.calm
    }

    var sad:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.sad
    }

    var sexy:Double? {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.sexy
    }
    
    var aggressive:Double?  {
        analyzedSpotifyTrack.asSpotifyTrack!.audioAnalysisV6.asAudioAnalysisV6Finished?.result.mood.aggressive
    }
    
    enum Moods: CaseIterable {
        case Aggressive
        case Happy
        case Calm
        case Romantic
        case Dark
        case Sad
        case Energetic
        case Sexy
    }
        
    func getMaxValue() {
        var max:Double? = 0.0
        
        for mood in Moods.allCases {
            switch mood {
            case .Energetic:
                if let val = energetic {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            case .Aggressive:
                if let val = aggressive {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            case .Calm:
                if let val = calm {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            case .Romantic:
                if let val = romantic {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            case .Dark:
                if let val = dark {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            case .Happy:
                if let val = happy {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            case .Sad:
                if let val = sad {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            case .Sexy:
                if let val = sexy {
                    if max! < val {
                        max! = maxMoods.updateMaxMoods(moodElement(mood: mood ,val: val))
                    }
                }
            }
        }
    }
}
