//
//  Small.swift
//  KnotClock
//
//  Created by NA on 2/28/23.
//

import SwiftUI

struct Small: View {
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
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
            if countdown.isForTomorrow {
                HStack {
                    Text("Tomorrow:").font(.footnote).bold().foregroundColor(.secondary)
                    Text(countdown.title).lineLimit(1).bold()
                }
            } else {
                Text(countdown.title).lineLimit(1).bold()
            }
            
            Spacer()
            
            if countdown.remainingSeconds >= 0 {
                timeView(remainingTime, .small, preferences)
                if countdown.isHidden {
                    Button {
                        Countdowns.shared.unhideDaily(countdown.id, isForTomorrow: countdown.isForTomorrow)
                    } label: {
                        Label("Unhide", systemImage: "eye").labelStyle(.iconOnly)
                    }
                }
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
        .contextualMenu(for: $countdown)
    }
    
    func getBackgroundColor() -> Color {
        let backgroundColor = (colorScheme == .dark) ? K.SmallCountdown.backgroundColorDarkMode : K.SmallCountdown.backgroundColorLightMode
        return getCountdownIndicationColor(remainingTime: remainingTime, defaultColor: backgroundColor, opacity: 0.2, preferences: preferences)
    }
}
