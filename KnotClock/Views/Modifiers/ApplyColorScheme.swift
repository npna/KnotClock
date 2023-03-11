//
//  ApplyColorScheme.swift
//  KnotClock
//
//  Created by NA on 3/11/23.
//

import SwiftUI

struct ApplyColorScheme: ViewModifier {
    @AppStorage(K.userPreferencesKey) var preferences = Preferences(x: DefaultUserPreferences())
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if let theme = preferences.x.preferredTheme.colorScheme {
            content.preferredColorScheme(theme)
        } else {
            content
        }
    }
}

extension View {
    func applyColorScheme() -> some View {
        self.modifier(ApplyColorScheme())
    }
}
