//
//  SpotifyAnalysisScreen.swift
//  XcodersGraphQL
//
//  Created by Jack Belding on 10/12/22.
//

import Foundation
import SwiftUI

struct SpotifyAnalysisScreen: View{
    
    @StateObject private var analyzedSongListVM = SpotifyAnalysisListViewModel()
    
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, world!")
//        }
        NavigationView{
            VStack{
                List(analyzedSongListVM.analyzedSongs, id: \.id){song in
                    Text(song.id)
    //                Button("Stats")
                }
                Spacer()
                Button(action: {analyzedSongListVM.printNetworkCalls()}){
                    Text("Print network calls")
                }
            }

        }
        .onAppear(perform: {
            analyzedSongListVM.populateRecentlyPlayedSongAnalysis()
        })
        .navigationTitle("Recently played songs")
        .padding()
    }
}
