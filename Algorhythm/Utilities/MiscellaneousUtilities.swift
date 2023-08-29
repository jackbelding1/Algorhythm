import Foundation
import SwiftUI
import SpotifyWebAPI

// mapping of cyanite genres to spotify genres
let cyaniteToSpotfiyTags:[String:[String]] = [
    "electronicDance":["edm", "dance", "dubstep", "house"],
    "rapHipHop":["rap"],
    "folkCountry":["country"],
    "rnb":["r-n-b"],
    "pop":["pop", "indie-pop"],
    "classical":["classical"],
    "rock":["grunge", "rock", "punk-rock", "hard-rock"],
    "reggae":["reggae", "reggaeton"],
    "metal":["metal"],
    "latin":["latin"],
    "jazz":["jazz"],
    "funkSoul":["funk"],
    "ambient":["ambient"],
    "blues":["blues"],
    "singerSongwriter":["indie"]
]

/**
 * List Node
 */
class Node<T> {

    var value: T
    var next: Node<T>?

    init(value: T, next: Node<T>? = nil) {
        self.value = value
        self.next = next
    }
}
/**
 * Singly linked list
 */
struct LinkedList<T> {
    mutating func append(_ value: T) {
        let node = Node(value: value)

        tail?.next = node
        tail = node
      }
 
    var head: Node<T>?
    var tail: Node<T>?
  
    var isEmpty: Bool { head == nil }
      
    init() {}
    
    mutating func initialize(withNode node:Node<T>) {
        head = node
        tail = node
    }
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
