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
                mood {
                  __typename
                  aggressive
                  energetic
                  dark
                  sad
                  happy
                  romantic
                  sad
                  sexy
                }
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
                  GraphQLField("mood", type: .nonNull(.object(Mood.selections))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(mood: Mood) {
                self.init(unsafeResultMap: ["__typename": "AudioAnalysisV6Result", "mood": mood.resultMap])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// The multi-label mood prediction for the whole audio.
              public var mood: Mood {
                get {
                  return Mood(unsafeResultMap: resultMap["mood"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "mood")
                }
              }

              public struct Mood: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["AudioAnalysisV6Mood"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("aggressive", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("energetic", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("dark", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("sad", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("happy", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("romantic", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("sad", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("sexy", type: .nonNull(.scalar(Double.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(aggressive: Double, energetic: Double, dark: Double, sad: Double, happy: Double, romantic: Double, sexy: Double) {
                  self.init(unsafeResultMap: ["__typename": "AudioAnalysisV6Mood", "aggressive": aggressive, "energetic": energetic, "dark": dark, "sad": sad, "happy": happy, "romantic": romantic, "sexy": sexy])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Mean prediction value for the "aggressive" mood.
                public var aggressive: Double {
                  get {
                    return resultMap["aggressive"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "aggressive")
                  }
                }

                /// Mean prediction value for the "energetic" mood.
                public var energetic: Double {
                  get {
                    return resultMap["energetic"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "energetic")
                  }
                }

                /// Mean prediction value for the "dark" mood.
                public var dark: Double {
                  get {
                    return resultMap["dark"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "dark")
                  }
                }

                /// Mean prediction value for the "sad" mood.
                public var sad: Double {
                  get {
                    return resultMap["sad"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "sad")
                  }
                }

                /// Mean prediction value for the "happy" mood.
                public var happy: Double {
                  get {
                    return resultMap["happy"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "happy")
                  }
                }

                /// Mean prediction value for the "romantic" mood.
                public var romantic: Double {
                  get {
                    return resultMap["romantic"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "romantic")
                  }
                }

                /// Mean prediction value for the "sexy" mood.
                public var sexy: Double {
                  get {
                    return resultMap["sexy"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "sexy")
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
