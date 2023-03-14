//
//  FullSize.swift
//  KnotClock
//
//  Created by NA on 2/27/23.
//

import SwiftUI

struct FullSize: View {
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
    
    @Environment(\.colorScheme) var colorScheme
    @State private var countdown: Countdown
    @State private var isShowing = false
    
    private var isInMenubar: Bool
    private let forcingExpired: Bool
    private let remainingTime: RemainingTimeDetails
    
    init(_ countdown: Countdown, isInMenubar: Bool = false, forcingExpired: Bool = false) {
        _countdown = State(initialValue: countdown)
        remainingTime = countdown.remainingTime
        self.isInMenubar = isInMenubar
        self.forcingExpired = forcingExpired
    }
    
    var body: some View {
        VStack {
            if isShowing {
                HStack {
                    let firstLetter = countdown.title.prefix(1).lowercased()
                    Image(systemName: "\(firstLetter).square.fill").font(.largeTitle)
                    
                    if countdown.isForTomorrow {
                        VStack(alignment: .leading) {
                            Text(countdown.title).bold().lineLimit(1)
                            Text("(tomorrow)").font(.footnote).bold()
                        }
                    } else {
                        Text(countdown.title).bold().lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if remainingTime.inSeconds > 0 {
                        timeView(remainingTime, .full, preferences)
                    } else if forcingExpired {
                        Button {
                            countdown.deleteExpiredSingleHideDaily()
                        } label: {
                            Label("Dismiss", systemImage: "checkmark.square")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(isInMenubar ? .identity : .slide)
                .padding()
                .background(getBackgroundColor().overlay {
                    getBGOverlay()
                })
                .cornerRadius(K.FullSizeCountdown.cornerRadius)
                .overlay {
                    RoundedRectangle(cornerRadius: K.FullSizeCountdown.cornerRadius)
                        .stroke(getBorderColor(), lineWidth: K.FullSizeCountdown.borderWidth)
                }
                .onChange(of: remainingTime.inSeconds) { _ in
                    checkIsShowing()
                }
            }
        }
        .onAppear {
            checkIsShowing()
        }
        .frame(minWidth: isInMenubar ? K.FrameSizes.Mac.Menubar.minWidth - K.FrameSizes.Mac.countdownVStackWidthSubtract : .none)
        .contextualMenu(for: $countdown)
    }
    
    func checkIsShowing() {
    // TODO: animation causes crash on macOS when FullSize countdown is inside ScrollView and only 1 countdown exists!
    //withAnimation {
        if forcingExpired {
            isShowing = true
        } else if remainingTime.inSeconds <= 1 {
            isShowing = false
        } else {
            isShowing = true
        }
    //}
    }
    
    func getBGOverlay() -> Image {
        var image = (colorScheme == .dark) ? K.Assets.fullSizeCountdownDarkBGOverlay : K.Assets.fullSizeCountdownLightBGOverlay
        let defaultImage = Image(image).resizable(resizingMode: .tile)
        
        switch whichIndication(remainingTime, preferences) {
        case .first:
            image = "\(preferences.x.firstCIColor.rawValue)BGOverlay"
        case .second:
            image = "\(preferences.x.secondCIColor.rawValue)BGOverlay"
        case .neither:
            return defaultImage
        }
        
        #if os(macOS)
        let finalImage = NSImage(named: image)
        #else
        let finalImage = UIImage(named: image)
        #endif
        
        if finalImage != nil {
            return Image(image).resizable(resizingMode: .tile)
        } else {
            return defaultImage
        }
    }
    
    func getBackgroundColor() -> Color {
        let backgroundColor = (colorScheme == .dark) ? K.FullSizeCountdown.backgroundColorDarkMode : K.FullSizeCountdown.backgroundColorLightMode
        return getCountdownIndicationColor(remainingTime: remainingTime, defaultColor: backgroundColor, opacity: 0.12, preferences: preferences)
    }
    
    func getBorderColor() -> Color {
        let borderColor = (colorScheme == .dark) ? K.FullSizeCountdown.borderColorDarkMode : K.FullSizeCountdown.borderColorLightMode
        return getCountdownIndicationColor(remainingTime: remainingTime, defaultColor: borderColor, opacity: 0.4, preferences: preferences)
    }
}

struct FullSize_Previews: PreviewProvider {
    static var previews: some View {
        FullSize(Countdown(id: UUID(), title: "Test", category: .daily, time: 500))
    }
}
