//
//  Constants.swift
//  KnotClock
//
//  Created by NA on 2/22/23.
//

import SwiftUI

typealias RemainingTimeDetails = (d: String, h: String, m: String, s: String, inSeconds: Int, category: CountdownCategory, formattedFullTime: String)

struct K {
    static let appName = "KnotClock"
    
    static let refreshThresholdHideSeconds: TimeInterval = 20
    static let timerAccuracyOptions: [(title: String, time: TimeInterval)] = [
        ("Lowest", 60),
        ("Super low", 20),
        ("Very low", 10),
        ("Low", 3),
        ("Normal", 1),
        ("High", 0.4),
        ("Very High", 0.2)
    ]
    
    static let dateFormat = "yyyy-MM-dd"
    static let notificationsLimit = 64
    
    static let menubarIconSize: CGFloat = 18
        
    static let minUpExSliderValue: Double = 1 // is Double to work with slider
    static let maxUpExSliderValue: Double = 10
    
    static let weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    static let weekdaysForSelection: [(name: String, isSelected: Bool)] = [
        ("Monday", false),
        ("Tuesday", false),
        ("Wednesday", false),
        ("Thursday", false),
        ("Friday", false),
        ("Saturday", false),
        ("Sunday", false)
    ]
    
    struct StorageKeys {
        static let userPreferences = "userPreferences" // Default Settings are in Preferences.swift file
        static let hiddenDailies = "HiddenDailyCountdowns"
        static let fetchedTomorrowDailies = "FetchedDailyCountdownsForTomorrow"
    }
    
    struct MacWindowSizes {
        struct Main {
            static let minWidth: CGFloat = 600
            static let minHeight: CGFloat = 400
        }
        
        struct Settings {
            static let minWidth: CGFloat = 550
            static let minHeight: CGFloat = 600
        }
        
        struct Overview {
            static let maxWidth: CGFloat = 600
        }
        
        struct Menubar {
            static let minWidth: CGFloat = 400
        }
        
        static let countdownVStackWidthSubtract: CGFloat = 30
    }
    
    struct Assets {
        static let logo = "KnotClockLogo"
        static let tinyAppIcon = "TinyAppIcon"
        static let menubarSimpleIcon = "MenubarSimpleIcon"
        static let fullSizeCountdownLightBGOverlay = "LightBGOverlay"
        static let fullSizeCountdownDarkBGOverlay = "DarkBGOverlay"
        // Other BGOverlay colors are stored in Colors.xcassets
    }
    
    struct FullSizeCountdown {
        static let backgroundColorLightMode = Color(red: 1, green: 1, blue: 1, opacity: 1.0)
        static let borderColorLightMode = Color(red: 0, green: 0, blue: 0, opacity: 0.3)
        static let backgroundColorDarkMode = Color(red: 1, green: 1, blue: 1, opacity: 0.1)
        static let borderColorDarkMode = Color(red: 0, green: 0, blue: 0, opacity: 0.3)
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 4
    }
    
    struct SmallCountdown {
        static let backgroundColorLightMode = Color(red: 0.83, green: 0.84, blue: 0.839, opacity: 1.0)
        static let backgroundColorDarkMode = Color(red: 0.237, green: 0.247, blue: 0.256, opacity: 1.0)
    }
    
    struct WeeklyOverview {
        static let weekdayNameColumnBG = Color(red: 0, green: 0, blue: 0, opacity: 0.05)
        static let borderColor = Color(red: 0, green: 0, blue: 0, opacity: 0.2)
    }
    
    struct TimeSliced {
        struct Full {
            static let minWidth: CGFloat = 38
            static let font: Font = .largeTitle
        }
        
        struct Focus {
            static let minWidth: CGFloat = 75
            static let font: Font = .system(size: 50)
        }
        
        struct Small {
            static let minWidth: CGFloat = 20
            static let font: Font = .body
        }
        
        static func getMinWidth(_ mode: TimeSlicedMode) -> CGFloat {
            switch mode {
            case .full:
                return Full.minWidth
            case .small:
                return Small.minWidth
            case .focus:
                return Focus.minWidth
            }
        }
        
        static func getFont(_ mode: TimeSlicedMode) -> Font {
            switch mode {
            case .full:
                return Full.font
            case .small:
                return Small.font
            case .focus:
                return Focus.font
            }
        }
    }
}

enum CountdownCategory {
    case daily
    case single
}

enum CountdownGroup {
    case current
    case upcomming
    case expired
}

enum TimeSlicedMode {
    case full
    case focus
    case small
}

enum WhichIndication {
    case first
    case second
    case neither
}
