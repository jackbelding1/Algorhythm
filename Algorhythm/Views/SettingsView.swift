import SwiftUI

// MARK: - SettingsView
struct SettingsView: View {
    // MARK: - Variables
    @EnvironmentObject var spotify: Spotify
    
    // MARK: - Body
    var body: some View {
        logoutButton
    }
    
    // MARK: - View Helpers
    private var logoutButton: some View {
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

// MARK: - SettingsView_Previews
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
