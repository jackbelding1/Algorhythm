import Foundation
import SwiftUI
import SpotifyWebAPI

func enumToString(_ toConvert:SpotifyAnalysisViewModel.Moods) -> String? {
    
    let mapping:[SpotifyAnalysisViewModel.Moods:String] = [
        .Energetic:"Energetic",
        .Aggressive:"Agressive",
        .Calm:"Calm",
        .Dark:"Dark",
        .Happy:"Happy",
        .Romantic:"Romantic",
        .Sexy:"Sexy",
        .Sad:"Sad"
    ]
    
    for mood in SpotifyAnalysisViewModel.Moods.allCases {
        if toConvert == mood {
            return mapping[mood]!
        }
    }
    return nil
}

extension View {
    
    /// Type erases self to `AnyView`. Equivalent to `AnyView(self)`.
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }

}

extension ProcessInfo {
    
    /// Whether or not this process is running within the context of a SwiftUI
    /// preview.
    var isPreviewing: Bool {
        return self.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

}
