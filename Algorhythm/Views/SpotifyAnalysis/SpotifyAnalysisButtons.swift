//
//  SpotifyAnalysisButtons.swift
//  Algorhythm
//
//  Created by Jack Belding on 8/15/23.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.primary).colorInvert()
            .background(Color.primary)
            .clipShape(Capsule())
            .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func customButtonStyle() -> some View {
        self.modifier(CustomButtonStyle())
    }
}

struct CustomButton: View {
    let action: () -> Void
    let content: () -> AnyView

    var body: some View {
        Button(action: action, label: content)
            .customButtonStyle()
    }
}
