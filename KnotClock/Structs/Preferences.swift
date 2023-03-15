//
//  Preferences.swift
//  KnotClock
//
//  Created by NA on 3/6/23.
//

import SwiftUI

struct Preferences<DefaultUserPreferences: Codable> {
    var x: DefaultUserPreferences
    
    mutating func resetAllTo(_ preferences: DefaultUserPreferences) {
        if let data = try? JSONEncoder().encode(preferences),
           let encoded = String(data: data, encoding: .utf8),
           let decoded = try? JSONDecoder().decode(DefaultUserPreferences.self, from: data)
        {
            let userDefaults = UserDefaults.standard
            userDefaults.set(encoded, forKey: K.StorageKeys.userPreferences)
            userDefaults.synchronize()
            
            x = decoded
            
            Countdowns.shared.reset(level: .refetchResetNotifs)
        }
    }
}

struct DefaultUserPreferences: Codable {
    var refreshTimerInterval = 1.0
    var showZeroHourMinute = false
    var showApplicationIn: MacSAISettings = .both
    var menubarIconSettings: MacMenubarIconSettings = .simpleIcon
    var menubarIconColoredSymbolName = "timer"
    var showMenubarExtra = true
    var showDockIcon = true
    
    var preferredTheme: Theme = .system
    
    var currentCountdownStyle: UpcommingAndExpiredSettings = .fullSize
    
    var upcommingCountdownStyle: UpcommingAndExpiredSettings = .small
    var maxUpcomming: Double = min(3, K.maxUpExSliderValue) // is Double to use with slider
    
    var expiredCountdownStyle: UpcommingAndExpiredSettings = .small
    var maxExpired: Double = min(2, K.maxUpExSliderValue)
    var autoHideExpiredDailies: Bool = false
    var autoRemoveExpiredSingles: Bool = false
    
    var ciRemainingSecondsMinValue = 5
    var ciRemainingSecondsMaxValue = 7200
    
    var includeSingleCountdownsInListSecondsEarlier = 86400 * 1 // 86400 = 1 day
    var includeTomorrowDailiesInTodaySecondsEarlier = 3600
    
    var firstCIEnabled = true
    var firstCIRemainingSeconds = 600
    var firstCIColor: ColorSets = .orange
    
    var secondCIEnabled = true
    var secondCIRemainingSeconds = 180
    var secondCIColor: ColorSets = .red
    
    // Do not change
    var launchAtLogin = false
    var notificationCenterAuthorized = false
    var notificationOnFirstIndication = false
    var notificationOnSecondIndication = false
    var notificationOnCountdownHitsZero = false
}

enum MacSAISettings: String, Codable, CaseIterable, Identifiable {
    case both = "Both"
    case dock = "Dock Icon"
    case menubar = "Menubar Icon"
    
    var id: String { self.rawValue }
}

enum UpcommingAndExpiredSettings: String, Codable, CaseIterable, Identifiable {
    case hide = "Hide"
    case tiny = "Tiny"
    case small = "Small"
    case fullSize = "Full Size"
    
    var id: String { self.rawValue }
}

enum MacMenubarIconSettings: String, Codable, CaseIterable, Identifiable {
    case simpleIcon = "Simple Icon"
    case appIcon = "App Icon"
    case coloredSymbol = "Colored Symbol"
    case simpleIconAndNextCountdown = "Simple Icon & Countdown Timer"
    case appIconAndNextCountdown = "App Icon & Countdown Timer"
    case coloredSymbolAndNextCountdown = "Colored Symbol & Countdown Timer"
    case nextCountdown = "Countdown Timer"
    
    var id: String { self.rawValue }
}

enum ColorSets: String, Codable, CaseIterable, Identifiable {
    case blue = "AppBlue"
    case green = "AppGreen"
    case orange = "AppOrange"
    case purple = "AppPurple"
    case red = "AppRed"
    case yellow = "AppYellow"
    
    var id: String { self.rawValue }
}

enum Theme: String, Codable, CaseIterable, Identifiable {
    case system = "System"
    case dark = "Dark Mode"
    case light = "Light Mode"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .dark:
            return ColorScheme.dark
        case .light:
            return ColorScheme.light
        case .system:
            return .none
        }
    }
}

extension Preferences: RawRepresentable {
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self.x),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        
        return json
    }

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(DefaultUserPreferences.self, from: data)
        else {
            return nil
        }
        
        self.x = decoded
    }
}
