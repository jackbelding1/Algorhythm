
import Foundation
import SwiftUI
import Combine
import RealmSwift


// MARK: - MoodOption
struct MoodOption {
    let emoji: String
    let color: Color
    let caption: String
}

// MARK: - GenrePreference
struct GenrePreference {
    let title: String
    let key: String
    var value: Bool
}

// MARK: - NewPlaylistViewModel
class NewPlaylistViewModel: ObservableObject {
    // MARK: - Variables
    let realmRepository = RealmRepository()
    
    // MARK: - Variables
    private var initialPreferenceState: [GenrePreference] = []
    @Published var genrePreferencesCollection: [GenrePreference] = []
    @Published var didTapUpdate: Bool = false
    @Published var selectedMood: String?
    @Published var isPresenting: Bool = false
    @Published var savePreferences = false
    
    // MARK: - Initializer
    public init() {
        savePreferences = UserDefaults.standard.bool(forKey: "shouldSavePreferences")
        initOptionPreferences()
        initialPreferenceState = genrePreferencesCollection
    }
    
    // MARK: - Public Methods
    
    // TODO: revise function design
    func getRandomGenreKey() -> String? {
        let trueGenrePreferences = genrePreferencesCollection.filter { $0.value == true }
        let selectedCollection = trueGenrePreferences.isEmpty ? genrePreferencesCollection : trueGenrePreferences
        guard !selectedCollection.isEmpty else { return nil }
        let randomIndex = Int.random(in: 0..<selectedCollection.count)
        return selectedCollection[randomIndex].key
    }
    func restorePreferences() {
        genrePreferencesCollection = initialPreferenceState
    }
    func handleTapUpdate() {
        if savePreferences {
            savePlaylistOptions()
        }
    }
    func updateSavePreferences(isMarked: Bool) {
        savePreferences = !isMarked
        UserDefaults.standard.set(savePreferences, forKey: "shouldSavePreferences")
    }
    func updateGenreSelection(id: String, isMarked: Bool) {
        for index in 0..<genrePreferencesCollection.count {
            if genrePreferencesCollection[index].key == id {
                genrePreferencesCollection[index].value = !isMarked
                break
            }
        }
    }
    func clearGenreSelections() {
        for index in 0..<genrePreferencesCollection.count {
            genrePreferencesCollection[index].value = false
        }
    }
    
    func moodOptionTapped(mood: String) {
        selectedMood = mood == selectedMood?.lowercased() ? nil : mood
        print("selected \(mood)")
    }
    
    // MARK: - Private Methods
    private func initOptionPreferences() {
        if savePreferences {
            do {
                try loadOptionPreferences()
            } catch {
                initDefaultOptions()
            }
        } else {
            initDefaultOptions()
        }
    }

    // Removed bool return type and use exception
    private func loadOptionPreferences() throws {
        if let preferences = realmRepository.loadPlaylistOptions() {
            processPreferences(preferences)
        } else {
            throw PreferenceError.loadFailed
        }
    }
    
    private func processPreferences(_ preferences:RealmSwift.List<PlaylistOption>) {
        for preference in preferences {
            guard let title = genreKeyToTitle[preference.genre] else {
                // Handle the case where the title is not found in the dictionary
                continue // Skip to the next iteration
            }
            genrePreferencesCollection.append(GenrePreference(title: title, key: preference.genre, value: preference.value))
        }
    }
    
    private func initDefaultOptions() {
        for genre in genreKeyToTitle {
            let preference = GenrePreference(title: genre.1, key: genre.0, value: false)
            genrePreferencesCollection.append(preference)
        }
    }
    
    private func savePlaylistOptions() {
        realmRepository.savePlaylistOptions(
            Dictionary(uniqueKeysWithValues:
                        genrePreferencesCollection.map {($0.key, $0.value)})
        )
    }
    
    // MARK: - Constants TODO Replace with configured genres/moods!!
    private let genreKeyToTitle: [String: String] = [
        "edm": "EDM",
        "country": "Country",
        "rap": "Hip-Hop/Rap"
    ]
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
}
// MARK: - Error codes
enum PreferenceError: Error {
    case loadFailed
}
