import SwiftUI
import Combine
import SpotifyWebAPI

// MARK: - RootView
struct RootView: View {
    // MARK: - Constants
    static let logoImageName = "algorhythmlogo"
    
    // MARK: - Variables
    @EnvironmentObject var spotify: Spotify
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: RootViewModel
    
    // MARK: - Initializer
    init(_ viewModel:RootViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack {
            if self.spotify.isAuthorized {
                authorizedView
                    .accessibility(identifier: "authorizedView")
            } else {
                unauthorizedView
                    .accessibility(identifier: "unauthorizedView")
            }
        }
        .modifier(LoginView())
        .alert(item: $viewModel.alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .onOpenURL { url in
            viewModel.handleAuthRedirectURL(url)
        }
    }
    
    // MARK: - View Helpers
    private var authorizedView: some View {
        HomeView()
            .id(appState.rootViewId)
            .accessibility(identifier: "homeView")
    }

    private var unauthorizedView: some View {
        VStack {
            Image("algorhythmlogo")
                .background(colorScheme == .dark ? Color.black : Color.white)
                .accessibility(identifier: "logoImage")
            Text("Algorhythm")
                .accessibility(identifier: "titleLabel")
            Spacer()
        }
    }
}
