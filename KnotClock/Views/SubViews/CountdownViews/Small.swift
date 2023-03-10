//
//  Small.swift
//  KnotClock
//
//  Created by NA on 2/28/23.
//

import SwiftUI

struct Small: View {
    @AppStorage(K.userPreferencesKey) var preferences = Preferences(x: DefaultUserPreferences())
    @State private var countdown: Countdown
    @Environment(\.colorScheme) var colorScheme
    private let remainingTime: RemainingTimeDetails
    
    init(_ countdown: Countdown) {
        _countdown = State(initialValue: countdown)
        remainingTime = countdown.remainingTime
    }
    
    var body: some View {
        let firstLetter = countdown.title.prefix(1).lowercased()
        HStack {
            Image(systemName: "\(firstLetter).square.fill").font(.footnote)
            Text(countdown.title).lineLimit(1).bold()
            
            Spacer()
            
            if countdown.remainingSeconds >= 0 {
                timeView(remainingTime, .small, preferences)
            } else {
                Button {
                    countdown.deleteExpiredSingleHideDaily()
                } label: {
                    Label("Dismiss", systemImage: "checkmark.square")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, .none)
        .padding(.vertical, 5)
        .background(getBackgroundColor())
        .cornerRadius(K.FullSizeCountdown.cornerRadius)
    }
    
    func getBackgroundColor() -> Color {
        let backgroundColor = (colorScheme == .dark) ? K.SmallCountdown.backgroundColorDarkMode : K.SmallCountdown.backgroundColorLightMode
        return getCountdownIndicationColor(remainingTime: remainingTime, defaultColor: backgroundColor, opacity: 0.2, preferences: preferences)
    }
}
