import Foundation
import SwiftUI
import SpotifyWebAPI

// mapping of cyanite genres to spotify genres
let cyanite2SpotfiyTags:[String:[String]] = [
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
 * The URI string for artist
 */
class artistURI: SpotifyURIConvertible {
    public var uri:String
    
    init(URI artistUri:String){
        self.uri = "spotify:artist:\(artistUri)"
    }
}
/**
 * convert spotify analysis view model mood to a string
 */
func enumToString(_ toConvert:SpotifyAnalysisModel.Moods) -> String? {
    
    let mapping:[SpotifyAnalysisModel.Moods:String] = [
        .Energetic:"Energetic",
        .Aggressive:"Agressive",
        .Calm:"Calm",
        .Dark:"Dark",
        .Happy:"Happy",
        .Romantic:"Romantic",
        .Sexy:"Sexy",
        .Sad:"Sad"
    ]
    
    for mood in SpotifyAnalysisModel.Moods.allCases {
        if toConvert == mood {
            return mapping[mood]!
        }
    }
    return nil
}
/**
 * Event Type
 */
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
//
// https://thinkdiff.net/how-to-create-checkbox-in-swiftui-ad08e285ab3d
//
//MARK:- Checkbox Field
struct CheckboxField: View {
    let id: String
    let label: String
    let size: CGFloat
    let color: Color
    let textSize: Int
    let callback: (String, Bool)->()
    var isMarked:Bool
    
    init(
        id: String,
        label:String,
        size: CGFloat = 10,
        color: Color = Color.black,
        textSize: Int = 14,
        callback: @escaping (String, Bool)->(),
        isMarked: Bool = false
        ) {
        self.id = id
        self.label = label
        self.size = size
        self.color = color
        self.textSize = textSize
        self.callback = callback
        self.isMarked = isMarked
    }
        
    var body: some View {
        Button(action:{
            self.callback(self.id, self.isMarked)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.isMarked ? "checkmark.square" : "square")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.size, height: self.size)
                Text(label)
                    .font(Font.system(size: size))
                    .foregroundColor(Color.accentColor)
                Spacer()
            }.foregroundColor(Color.accentColor)
        }
        .foregroundColor(Color.white)
    }
}
