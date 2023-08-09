import SwiftUI
import Combine

struct MoodOption {
    let emoji: String
    let color: Color
    let caption: String
}


class MoodSelectionViewModel: ObservableObject {
    @Published var didTapUpdate: Bool = false
    @Published var selectedMood: String?
    @Published var isPresenting: Bool = false
    @Published var playlistOptionsCopy = PlaylistOptionsViewModel()
    @Published var playlistOptions = PlaylistOptionsViewModel()
    @Published var savePreferences = false

    let moodOptions: [MoodOption] = [
        MoodOption(emoji: "🔥", color: .red, caption: "Aggressive"),
        MoodOption(emoji: "🤠", color: .yellow, caption: "Happy"),
        MoodOption(emoji: "🌴", color: .green, caption: "Calm"),
        MoodOption(emoji: "💗", color: .pink, caption: "Romantic"),
        MoodOption(emoji: "😈", color: .gray, caption: "Dark"),
        MoodOption(emoji: "😪", color: .blue, caption: "Sad"),
        MoodOption(emoji: "⚡️", color: .orange, caption: "Energetic"),
        MoodOption(emoji: "💦", color: .purple, caption: "Sexy"),
    ]

    func moodOptionTapped(mood: String) {
        selectedMood = mood == selectedMood?.lowercased() ? nil : mood
        print("selected \(mood)")
    }
}
