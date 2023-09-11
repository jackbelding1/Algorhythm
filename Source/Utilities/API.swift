// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct SpotifyTrackEnqueueInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spotifyTrackId
  public init(spotifyTrackId: GraphQLID) {
    graphQLMap = ["spotifyTrackId": spotifyTrackId]
  }

  public var spotifyTrackId: GraphQLID {
    get {
      return graphQLMap["spotifyTrackId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spotifyTrackId")
    }
  }
}

/// Describes all possible genre tags.
public enum AudioAnalysisV6GenreTags: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Ambient
  case ambient
  /// Blues
  case blues
  /// Classical
  case classical
  /// Electronic/Dance
  case electronicDance
  /// Folk/Country
  case folkCountry
  /// Jazz
  case jazz
  /// Funk/Soul
  case funkSoul
  /// Latin
  case latin
  /// Metal
  case metal
  /// Pop
  case pop
  /// Rap/Hip-Hop
  case rapHipHop
  /// Reggae
  case reggae
  /// RnB
  case rnb
  /// Rock
  case rock
  /// Singer/Songwriter
  case singerSongwriter
  @available(*, deprecated, message: "country is now a subgenre. Please do not use this value anymore and instead refer to the corresponding subgenre values.")
  case country
  @available(*, deprecated, message: "indieAlternative is now a subgenre. Please do not use this value anymore and instead refer to the corresponding subgenre values.")
  case indieAlternative
  @available(*, deprecated, message: "punk is now a subgenre. Please do not use this value anymore and instead refer to the corresponding subgenre values.")
  case punk
  @available(*, deprecated, message: "folk is now a subgenre. Please do not use this value anymore and instead refer to the corresponding subgenre values.")
  case folk
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ambient": self = .ambient
      case "blues": self = .blues
      case "classical": self = .classical
      case "electronicDance": self = .electronicDance
      case "folkCountry": self = .folkCountry
      case "jazz": self = .jazz
      case "funkSoul": self = .funkSoul
      case "latin": self = .latin
      case "metal": self = .metal
      case "pop": self = .pop
      case "rapHipHop": self = .rapHipHop
      case "reggae": self = .reggae
      case "rnb": self = .rnb
      case "rock": self = .rock
      case "singerSongwriter": self = .singerSongwriter
      case "country": self = .country
      case "indieAlternative": self = .indieAlternative
      case "punk": self = .punk
      case "folk": self = .folk
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .ambient: return "ambient"
      case .blues: return "blues"
      case .classical: return "classical"
      case .electronicDance: return "electronicDance"
      case .folkCountry: return "folkCountry"
      case .jazz: return "jazz"
      case .funkSoul: return "funkSoul"
      case .latin: return "latin"
      case .metal: return "metal"
      case .pop: return "pop"
      case .rapHipHop: return "rapHipHop"
      case .reggae: return "reggae"
      case .rnb: return "rnb"
      case .rock: return "rock"
      case .singerSongwriter: return "singerSongwriter"
      case .country: return "country"
      case .indieAlternative: return "indieAlternative"
      case .punk: return "punk"
      case .folk: return "folk"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: AudioAnalysisV6GenreTags, rhs: AudioAnalysisV6GenreTags) -> Bool {
    switch (lhs, rhs) {
      case (.ambient, .ambient): return true
      case (.blues, .blues): return true
      case (.classical, .classical): return true
      case (.electronicDance, .electronicDance): return true
      case (.folkCountry, .folkCountry): return true
      case (.jazz, .jazz): return true
      case (.funkSoul, .funkSoul): return true
      case (.latin, .latin): return true
      case (.metal, .metal): return true
      case (.pop, .pop): return true
      case (.rapHipHop, .rapHipHop): return true
      case (.reggae, .reggae): return true
      case (.rnb, .rnb): return true
      case (.rock, .rock): return true
      case (.singerSongwriter, .singerSongwriter): return true
      case (.country, .country): return true
      case (.indieAlternative, .indieAlternative): return true
      case (.punk, .punk): return true
      case (.folk, .folk): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [AudioAnalysisV6GenreTags] {
    return [
      .ambient,
      .blues,
      .classical,
      .electronicDance,
      .folkCountry,
      .jazz,
      .funkSoul,
      .latin,
      .metal,
      .pop,
      .rapHipHop,
      .reggae,
      .rnb,
      .rock,
      .singerSongwriter,
      .country,
      .indieAlternative,
      .punk,
      .folk,
    ]
  }
}

/// Describes all possible mood tags.
public enum AudioAnalysisV6MoodTags: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case aggressive
  case calm
  case chilled
  case dark
  case energetic
  case epic
  case happy
  case romantic
  case sad
  case scary
  case sexy
  case ethereal
  case uplifting
  case ambiguous
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "aggressive": self = .aggressive
      case "calm": self = .calm
      case "chilled": self = .chilled
      case "dark": self = .dark
      case "energetic": self = .energetic
      case "epic": self = .epic
      case "happy": self = .happy
      case "romantic": self = .romantic
      case "sad": self = .sad
      case "scary": self = .scary
      case "sexy": self = .sexy
      case "ethereal": self = .ethereal
      case "uplifting": self = .uplifting
      case "ambiguous": self = .ambiguous
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .aggressive: return "aggressive"
      case .calm: return "calm"
      case .chilled: return "chilled"
      case .dark: return "dark"
      case .energetic: return "energetic"
      case .epic: return "epic"
      case .happy: return "happy"
      case .romantic: return "romantic"
      case .sad: return "sad"
      case .scary: return "scary"
      case .sexy: return "sexy"
      case .ethereal: return "ethereal"
      case .uplifting: return "uplifting"
      case .ambiguous: return "ambiguous"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: AudioAnalysisV6MoodTags, rhs: AudioAnalysisV6MoodTags) -> Bool {
    switch (lhs, rhs) {
      case (.aggressive, .aggressive): return true
      case (.calm, .calm): return true
      case (.chilled, .chilled): return true
      case (.dark, .dark): return true
      case (.energetic, .energetic): return true
      case (.epic, .epic): return true
      case (.happy, .happy): return true
      case (.romantic, .romantic): return true
      case (.sad, .sad): return true
      case (.scary, .scary): return true
      case (.sexy, .sexy): return true
      case (.ethereal, .ethereal): return true
      case (.uplifting, .uplifting): return true
      case (.ambiguous, .ambiguous): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [AudioAnalysisV6MoodTags] {
    return [
      .aggressive,
      .calm,
      .chilled,
      .dark,
      .energetic,
      .epic,
      .happy,
      .romantic,
      .sad,
      .scary,
      .sexy,
      .ethereal,
      .uplifting,
      .ambiguous,
    ]
  }
}

public final class SpotifyTrackEnqueueMutationMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SpotifyTrackEnqueueMutation($input: SpotifyTrackEnqueueInput!) {
      spotifyTrackEnqueue(input: $input) {
        __typename
        ... on SpotifyTrackEnqueueSuccess {
          __typename
          enqueuedSpotifyTrack {
            __typename
            id
          }
        }
        ... on Error {
          __typename
          message
        }
      }
    }
    """

  public let operationName: String = "SpotifyTrackEnqueueMutation"

  public var input: SpotifyTrackEnqueueInput

  public init(input: SpotifyTrackEnqueueInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("spotifyTrackEnqueue", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SpotifyTrackEnqueue.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(spotifyTrackEnqueue: SpotifyTrackEnqueue) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "spotifyTrackEnqueue": spotifyTrackEnqueue.resultMap])
    }

    /// Enqueue a SpotifyTrack.
    public var spotifyTrackEnqueue: SpotifyTrackEnqueue {
      get {
        return SpotifyTrackEnqueue(unsafeResultMap: resultMap["spotifyTrackEnqueue"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "spotifyTrackEnqueue")
      }
    }

    public struct SpotifyTrackEnqueue: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SpotifyTrackEnqueueError", "SpotifyTrackEnqueueSuccess"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLTypeCase(
            variants: ["SpotifyTrackEnqueueSuccess": AsSpotifyTrackEnqueueSuccess.selections, "SpotifyTrackEnqueueError": AsSpotifyTrackEnqueueError.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeSpotifyTrackEnqueueSuccess(enqueuedSpotifyTrack: AsSpotifyTrackEnqueueSuccess.EnqueuedSpotifyTrack) -> SpotifyTrackEnqueue {
        return SpotifyTrackEnqueue(unsafeResultMap: ["__typename": "SpotifyTrackEnqueueSuccess", "enqueuedSpotifyTrack": enqueuedSpotifyTrack.resultMap])
      }

      public static func makeSpotifyTrackEnqueueError(message: String) -> SpotifyTrackEnqueue {
        return SpotifyTrackEnqueue(unsafeResultMap: ["__typename": "SpotifyTrackEnqueueError", "message": message])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asSpotifyTrackEnqueueSuccess: AsSpotifyTrackEnqueueSuccess? {
        get {
          if !AsSpotifyTrackEnqueueSuccess.possibleTypes.contains(__typename) { return nil }
          return AsSpotifyTrackEnqueueSuccess(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsSpotifyTrackEnqueueSuccess: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SpotifyTrackEnqueueSuccess"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("enqueuedSpotifyTrack", type: .nonNull(.object(EnqueuedSpotifyTrack.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(enqueuedSpotifyTrack: EnqueuedSpotifyTrack) {
          self.init(unsafeResultMap: ["__typename": "SpotifyTrackEnqueueSuccess", "enqueuedSpotifyTrack": enqueuedSpotifyTrack.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var enqueuedSpotifyTrack: EnqueuedSpotifyTrack {
          get {
            return EnqueuedSpotifyTrack(unsafeResultMap: resultMap["enqueuedSpotifyTrack"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "enqueuedSpotifyTrack")
          }
        }

        public struct EnqueuedSpotifyTrack: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SpotifyTrack"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID) {
            self.init(unsafeResultMap: ["__typename": "SpotifyTrack", "id": id])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The ID of the track on Spotify. It can be used for fetching additional information for the Spotify API.
          /// For further information check out the Spotify Web API Documentation. https://developer.spotify.com/documentation/web-api/
          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }
        }
      }

      public var asSpotifyTrackEnqueueError: AsSpotifyTrackEnqueueError? {
        get {
          if !AsSpotifyTrackEnqueueError.possibleTypes.contains(__typename) { return nil }
          return AsSpotifyTrackEnqueueError(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsSpotifyTrackEnqueueError: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SpotifyTrackEnqueueError"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("message", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(message: String) {
          self.init(unsafeResultMap: ["__typename": "SpotifyTrackEnqueueError", "message": message])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var message: String {
          get {
            return resultMap["message"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "message")
          }
        }
      }
    }
  }
}

public final class SpotifyTrackQueryQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query SpotifyTrackQuery($id: ID!) {
      spotifyTrack(id: $id) {
        __typename
        ... on SpotifyTrackError {
          __typename
          message
        }
        ... on SpotifyTrack {
          __typename
          id
          audioAnalysisV6 {
            __typename
            ... on AudioAnalysisV6Finished {
              __typename
              result {
                __typename
                genreTags
                moodTags
              }
            }
          }
        }
      }
    }
    """

  public let operationName: String = "SpotifyTrackQuery"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("spotifyTrack", arguments: ["id": GraphQLVariable("id")], type: .nonNull(.object(SpotifyTrack.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(spotifyTrack: SpotifyTrack) {
      self.init(unsafeResultMap: ["__typename": "Query", "spotifyTrack": spotifyTrack.resultMap])
    }

    /// Retrieve a SpotifyTrack via ID.
    public var spotifyTrack: SpotifyTrack {
      get {
        return SpotifyTrack(unsafeResultMap: resultMap["spotifyTrack"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "spotifyTrack")
      }
    }

    public struct SpotifyTrack: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SpotifyTrackError", "SpotifyTrack"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLTypeCase(
            variants: ["SpotifyTrackError": AsSpotifyTrackError.selections, "SpotifyTrack": AsSpotifyTrack.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeSpotifyTrackError(message: String) -> SpotifyTrack {
        return SpotifyTrack(unsafeResultMap: ["__typename": "SpotifyTrackError", "message": message])
      }

      public static func makeSpotifyTrack(id: GraphQLID, audioAnalysisV6: AsSpotifyTrack.AudioAnalysisV6) -> SpotifyTrack {
        return SpotifyTrack(unsafeResultMap: ["__typename": "SpotifyTrack", "id": id, "audioAnalysisV6": audioAnalysisV6.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asSpotifyTrackError: AsSpotifyTrackError? {
        get {
          if !AsSpotifyTrackError.possibleTypes.contains(__typename) { return nil }
          return AsSpotifyTrackError(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsSpotifyTrackError: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SpotifyTrackError"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("message", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(message: String) {
          self.init(unsafeResultMap: ["__typename": "SpotifyTrackError", "message": message])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var message: String {
          get {
            return resultMap["message"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "message")
          }
        }
      }

      public var asSpotifyTrack: AsSpotifyTrack? {
        get {
          if !AsSpotifyTrack.possibleTypes.contains(__typename) { return nil }
          return AsSpotifyTrack(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsSpotifyTrack: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SpotifyTrack"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("audioAnalysisV6", type: .nonNull(.object(AudioAnalysisV6.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, audioAnalysisV6: AudioAnalysisV6) {
          self.init(unsafeResultMap: ["__typename": "SpotifyTrack", "id": id, "audioAnalysisV6": audioAnalysisV6.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The ID of the track on Spotify. It can be used for fetching additional information for the Spotify API.
        /// For further information check out the Spotify Web API Documentation. https://developer.spotify.com/documentation/web-api/
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var audioAnalysisV6: AudioAnalysisV6 {
          get {
            return AudioAnalysisV6(unsafeResultMap: resultMap["audioAnalysisV6"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "audioAnalysisV6")
          }
        }

        public struct AudioAnalysisV6: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["AudioAnalysisV6NotStarted", "AudioAnalysisV6Enqueued", "AudioAnalysisV6Processing", "AudioAnalysisV6Finished", "AudioAnalysisV6Failed"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLTypeCase(
                variants: ["AudioAnalysisV6Finished": AsAudioAnalysisV6Finished.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeAudioAnalysisV6NotStarted() -> AudioAnalysisV6 {
            return AudioAnalysisV6(unsafeResultMap: ["__typename": "AudioAnalysisV6NotStarted"])
          }

          public static func makeAudioAnalysisV6Enqueued() -> AudioAnalysisV6 {
            return AudioAnalysisV6(unsafeResultMap: ["__typename": "AudioAnalysisV6Enqueued"])
          }

          public static func makeAudioAnalysisV6Processing() -> AudioAnalysisV6 {
            return AudioAnalysisV6(unsafeResultMap: ["__typename": "AudioAnalysisV6Processing"])
          }

          public static func makeAudioAnalysisV6Failed() -> AudioAnalysisV6 {
            return AudioAnalysisV6(unsafeResultMap: ["__typename": "AudioAnalysisV6Failed"])
          }

          public static func makeAudioAnalysisV6Finished(result: AsAudioAnalysisV6Finished.Result) -> AudioAnalysisV6 {
            return AudioAnalysisV6(unsafeResultMap: ["__typename": "AudioAnalysisV6Finished", "result": result.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var asAudioAnalysisV6Finished: AsAudioAnalysisV6Finished? {
            get {
              if !AsAudioAnalysisV6Finished.possibleTypes.contains(__typename) { return nil }
              return AsAudioAnalysisV6Finished(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsAudioAnalysisV6Finished: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["AudioAnalysisV6Finished"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("result", type: .nonNull(.object(Result.selections))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(result: Result) {
              self.init(unsafeResultMap: ["__typename": "AudioAnalysisV6Finished", "result": result.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var result: Result {
              get {
                return Result(unsafeResultMap: resultMap["result"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "result")
              }
            }

            public struct Result: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["AudioAnalysisV6Result"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("genreTags", type: .nonNull(.list(.nonNull(.scalar(AudioAnalysisV6GenreTags.self))))),
                  GraphQLField("moodTags", type: .nonNull(.list(.nonNull(.scalar(AudioAnalysisV6MoodTags.self))))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(genreTags: [AudioAnalysisV6GenreTags], moodTags: [AudioAnalysisV6MoodTags]) {
                self.init(unsafeResultMap: ["__typename": "AudioAnalysisV6Result", "genreTags": genreTags, "moodTags": moodTags])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var genreTags: [AudioAnalysisV6GenreTags] {
                get {
                  return resultMap["genreTags"]! as! [AudioAnalysisV6GenreTags]
                }
                set {
                  resultMap.updateValue(newValue, forKey: "genreTags")
                }
              }

              /// List of mood tags the audio is classified with.
              public var moodTags: [AudioAnalysisV6MoodTags] {
                get {
                  return resultMap["moodTags"]! as! [AudioAnalysisV6MoodTags]
                }
                set {
                  resultMap.updateValue(newValue, forKey: "moodTags")
                }
              }
            }
          }
        }
      }
    }
  }
}
