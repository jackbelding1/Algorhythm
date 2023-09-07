import XCTest
import SwiftUI
import Combine
import SpotifyWebAPI
//import ViewInspector
@testable import Algorhythm

class RootViewTests: XCTestCase {

    var spotify: Spotify!
//    var appState: AppState!
//    var viewModel: RootViewModel!

    override func setUp() {
        super.setUp()
//        spotify = Spotify()
//        appState = AppState()
//        viewModel = RootViewModel(spotify: Spotify())
    }

    func testRootView_WhenAuthorized_ShowsHomeView() {
//        spotify.isAuthorized = true
//        let rootView = RootView(viewModel)
//            .environmentObject(spotify)
//            .environmentObject(appState)

//        do {
//            // Use ViewInspector to assert that HomeView is present
//            let homeView = try rootView.inspect().vStack().view(HomeView.self, 0)
//            XCTAssertNotNil(homeView) // Assert that HomeView is present
//        } catch {
//            XCTFail("Failed to inspect the view: \(error)")
//        }
    }


    func testRootView_WhenUnauthorized_ShowsUnauthorizedView() {
//        spotify.isAuthorized = false
//        let rootView = RootView(viewModel)
//            .environmentObject(spotify)
//            .environmentObject(appState)

        // Use any SwiftUI testing library to assert that unauthorizedView is present
    }

    func testRootView_AlertPresentation() {
        // Trigger the condition that shows the alert in your viewModel
//        viewModel.alert = .init(title: Text("Error"), message: Text("An error occurred"))
//
//        let rootView = RootView(viewModel)
//            .environmentObject(spotify)
//            .environmentObject(appState)

        // Use any SwiftUI testing library to assert that an alert is presented
    }

    func testRootView_HandleAuthRedirectURL() {
//        let testURL = URL(string: "your-test-url")!
//
//        let rootView = RootView(viewModel)
//            .environmentObject(spotify)
//            .environmentObject(appState)
//
//        rootView.onOpenURL(perform: { url in
//            self.viewModel.handleAuthRedirectURL(url)
//        })

        // Assert that the viewModel handled the URL correctly
    }
}
