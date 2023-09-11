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

class Event<T> {

  typealias EventHandler = (T) -> ()

  private var eventHandlers = [EventHandler]()

  func addHandler(handler: @escaping EventHandler) {
    eventHandlers.append(handler)
  }

  func raise(data: T) {
    for handler in eventHandlers {
      handler(data)
    }
  }
}

class Node<T> {

    var value: T
    var next: Node<T>?

    init(value: T, next: Node<T>? = nil) {
        self.value = value
        self.next = next
    }
}

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
