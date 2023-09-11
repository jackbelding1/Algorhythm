# Algorhythm 🎶

![Algorhythm Demo](https://drive.google.com/uc?id=1I70HgWi2X7B1ckRMMoDOjE5rOiEmmiFe/view?usp=sharing)

## Philosophy 🌱

Algorhythm was designed with a single goal in mind: to empower users. By providing genre and mood analysis, Algorhythm revolutionizes the way you create Spotify playlists.

## Architecture 🏗️

### Design Pattern
- **MVVM Architecture**: Enhanced with a repository pattern for data management.

### Third-Party Frameworks/Services
- Apollo iOS Client
- Realm DB
- Spotify WebAPI
- Cyanite Music Tagging Services
- Peter Schorn's Swift Spotify API Wrapper

## Installation 🛠️

### App Store 📱
Install Algorhythm from the [App Store](https://apps.apple.com/us/app/algorhythm-instant-playlists/id6446463438).

### GitHub 💻

#### Cyanite API
1. Create a new integration in the Cyanite dashboard.
2. Add the access token in Source -> Utilities -> ApolloNetwork.

```swift
let accessToken = "<your_token>"
```

#### Spotify API
1. Create a new integration in the Spotify Developer Dashboard.
2. Navigate to `Source -> Utilities -> Spotify`.
3. Replace the following code with your specific credentials:

```swift
private static let clientId = "<your_client_id>"
private static let clientSecret = "<your_client_secret>"
let loginCallbackURL = URL(string: "<your_login_callback_url>")!
```

Steps

1. Clone the repository: git clone https://github.com/jackbelding1/Algorhythm.git
2. Install required dependencies.
3. Build and run the project on a simulator or physical device.

Contributing 🤝

Feel free to contribute by creating issues or submitting pull requests.
License 📝

This project is licensed under the MIT License.
