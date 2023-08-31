import Foundation
import SwiftUI
import SpotifyWebAPI

// MARK: - Mappings
/// Mapping of Cyanite genres to Spotify genres
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

// MARK: - Data Structures
/// List Node
class Node<T> {
    var value: T
    var next: Node<T>?
    
    init(value: T, next: Node<T>? = nil) {
        self.value = value
        self.next = next
    }
}

/// Singly linked list
struct LinkedList<T> {
    private(set) var head: Node<T>?
    private(set) var tail: Node<T>?
    
    var isEmpty: Bool { head == nil }
    
    init() {}
    
    /// Appends a new node with given value to the end of the list
    mutating func append(_ value: T) {
        let newNode = Node(value: value)
        tail?.next = newNode
        tail = newNode
        if head == nil { head = newNode }
    }
    
    /// Initialize the linked list with a node
    mutating func initialize(with node: Node<T>) {
        head = node
        tail = node
    }
}
// MARK: - Process Info Extensions
extension ProcessInfo {
    
    /// Whether or not this process is running within the context of a SwiftUI
    /// preview.
    var isPreviewing: Bool {
        return self.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
