import SwiftUI
import Combine
import SpotifyWebAPI

struct RootView: View {
    
    @EnvironmentObject var spotify: Spotify
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State private var alert: AlertItem? = nil
    @State private var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        VStack{
            if (self.spotify.isAuthorized) {
                HomeView()
                    .environmentObject(spotify)
                    .id(appState.rootViewId)
            }
            else {
                VStack{
                    Image("algorhythmlogo")
                        .background(colorScheme == .dark ? Color.black : Color.white)

                    Text("Algorhythm")
                    Spacer()
                }
            }
        }
        // The login view is presented if `Spotify.isAuthorized` == `false. When
        // the login button is tapped, `Spotify.authorize()` is called. After
        // the login process successfully completes, `Spotify.isAuthorized` will
        // be set to `true` and `LoginView` will be dismissed, allowing the user
        // to interact with the rest of the app.
        .modifier(LoginView())
        // Presented if an error occurs during the process of authorizing with
        // the user's Spotify account.
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        // Called when a redirect is received from Spotify.
        .onOpenURL(perform: handleURL(_:))
        
    }
    
    /**
     Handle the URL that Spotify redirects to after the user Either authorizes
     or denies authorization for the application.

     This method is called by the `onOpenURL(perform:)` view modifier directly
     above.
     */
    func handleURL(_ url: URL) {
        
        // **Always** validate URLs; they offer a potential attack vector into
        // your app.
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            self.alert = AlertItem(
                title: "Cannot Handle Redirect",
                message: "Unexpected URL"
            )
            return
        }
        
        print("received redirect from Spotify: '\(url)'")
        
        // This property is used to display an activity indicator in `LoginView`
        // indicating that the access and refresh tokens are being retrieved.
        spotify.isRetrievingTokens = true
        
        // Complete the authorization process by requesting the access and
        // refresh tokens.
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // This value must be the same as the one used to create the
            // authorization URL. Otherwise, an error will be thrown.
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            // Whether the request succeeded or not, we need to remove the
            // activity indicator.
            self.spotify.isRetrievingTokens = false
            
            /*
             After the access and refresh tokens are retrieved,
             `SpotifyAPI.authorizationManagerDidChange` will emit a signal,
             causing `Spotify.authorizationManagerDidChange()` to be called,
             which will dismiss the loginView if the app was successfully
             authorized by setting the @Published `Spotify.isAuthorized`
             property to `true`.

             The only thing we need to do here is handle the error and show it
             to the user if one was received.
             */
            if case .failure(let error) = completion {
                print("couldn't retrieve access and refresh tokens:\n\(error)")
                let alertTitle: String
                let alertMessage: String
                if let authError = error as? SpotifyAuthorizationError,
                   authError.accessWasDenied {
                    alertTitle = "You Denied The Authorization Request :("
                    alertMessage = ""
                }
                else {
                    alertTitle =
                        "Couldn't Authorization With Your Account"
                    alertMessage = error.localizedDescription
                }
                self.alert = AlertItem(
                    title: alertTitle, message: alertMessage
                )
            }
        })
        .store(in: &cancellables)
        
        // MARK: IMPORTANT: generate a new value for the state parameter after
        // MARK: each authorization request. This ensures an incoming redirect
        // MARK: from Spotify was the result of a request made by this app, and
        // MARK: and not an attacker.
        self.spotify.authorizationState = String.randomURLSafe(length: 128)
        
    }
    
    /// Removes the authorization information for the user.
    var logoutButton: some View {
        // Calling `spotify.api.authorizationManager.deauthorize` will cause
        // `SpotifyAPI.authorizationManagerDidDeauthorize` to emit a signal,
        // which will cause `Spotify.authorizationManagerDidDeauthorize()` to be
        // called.
        Button(action: spotify.api.authorizationManager.deauthorize, label: {
            Text("Logout")
                .foregroundColor(.white)
                .padding(7)
                .background(
                    Color(red: 0.392, green: 0.720, blue: 0.197)
                )
                .cornerRadius(10)
                .shadow(radius: 3)
            
        })
    }
}

struct RootView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        RootView()
            .environmentObject(spotify)
    }
}