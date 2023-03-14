//
//  MacMenubar.swift
//  KnotClock
//
//  Created by NA on 3/3/23.
//

import SwiftUI

#if os(macOS)
class MacMenubar: ObservableObject {
    private var countdowns = Countdowns.shared
    
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
    
    @ViewBuilder
    func menubarIcon() -> some View {
        switch preferences.x.menubarIconSettings {
        
        case .simpleIcon, .appIcon:
            menubarImageIcon(imageType: preferences.x.menubarIconSettings)
        
        case .coloredSymbol:
            menubarColoredSymbolIcon()
        
        case .simpleIconAndNextCountdown, .appIconAndNextCountdown:
            menubarImageIcon(imageType: preferences.x.menubarIconSettings)
            menubarRemainingTime()
        
        case .coloredSymbolAndNextCountdown:
            menubarColoredSymbolIcon()
            menubarRemainingTime()
        
        case .nextCountdown:
            menubarRemainingTime()
        
        }
    }
    
    func menubarImageIcon(imageType: MacMenubarIconSettings) -> Image {
        let defaultImage = Image(systemName: preferences.x.menubarIconColoredSymbolName) // Defaults to Symbol
        var nsImage: NSImage? = nil
        
        switch imageType {
        case .appIcon, .appIconAndNextCountdown:
            nsImage = NSImage(named: K.Assets.tinyAppIcon)
        case .simpleIcon, .simpleIconAndNextCountdown:
            nsImage = NSImage(named: K.Assets.menubarSimpleIcon)
        default:
            return defaultImage
        }
        
        if let nsImage {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = K.menubarIconSize
                $0.size.width = K.menubarIconSize / ratio
                return $0
            }(nsImage)
            return Image(nsImage: image)
        }
        
        return defaultImage
    }
    
    func menubarColoredSymbolIcon() -> Image {
        let image = NSImage(systemSymbolName: preferences.x.menubarIconColoredSymbolName, accessibilityDescription: nil)
        var configuration = NSImage.SymbolConfiguration(pointSize: K.menubarIconSize, weight: .light)
        var color: Color = Color(preferences.x.firstCIColor.rawValue)
        var defaultIcon = Image(systemName: preferences.x.menubarIconColoredSymbolName)

        if let updatedImage = image?.withSymbolConfiguration(configuration) {
            defaultIcon = Image(nsImage: updatedImage)
        }
        
        guard let remainingSeconds = nextCountdownRemainingTime()?.inSeconds else {
            return defaultIcon
        }
        
        if remainingSeconds > preferences.x.firstCIRemainingSeconds && remainingSeconds > preferences.x.secondCIRemainingSeconds {
            return defaultIcon
        }
        
        if (preferences.x.firstCIRemainingSeconds < preferences.x.secondCIRemainingSeconds && remainingSeconds > preferences.x.firstCIRemainingSeconds)
        || (preferences.x.firstCIRemainingSeconds > preferences.x.secondCIRemainingSeconds && remainingSeconds < preferences.x.secondCIRemainingSeconds)
        {
            color = Color(preferences.x.secondCIColor.rawValue)
            if !preferences.x.secondCIEnabled {
                return defaultIcon
            }
        } else if !preferences.x.firstCIEnabled {
            return defaultIcon
        }
        
        configuration = configuration.applying(.init(paletteColors: [NSColor(color)]))
        if let updatedImage = image?.withSymbolConfiguration(configuration) {
            return Image(nsImage: updatedImage)
        }
        
        return defaultIcon
    }
    
    @ViewBuilder
    func menubarRemainingTime() -> some View {
        if let nextCountdown = nextCountdownRemainingTime() {
            let formattedFullTime = (preferences.x.refreshTimerInterval >= K.refreshThresholdHideSeconds) ? String(nextCountdown.formattedFullTime.dropLast(3)) : nextCountdown.formattedFullTime
            Text(formattedFullTime).frame(maxWidth: 20).minimumScaleFactor(0.5)
        } else if preferences.x.menubarIconSettings == .nextCountdown {
            Text("No Countdown")
        } else {
            Text("")
        }
    }
    
    func nextCountdownRemainingTime() -> RemainingTimeDetails? {
        return countdowns.current.first?.remainingTime
    }
}
#endif
