//
//  CommonViewExtensions.swift
//  KnotClock
//
//  Created by NA on 3/9/23.
//

import SwiftUI

extension View {
    // Countdown Views
    func tiny(_ cds: [Countdown]) -> some View {
        let width = K.FrameSizes.AllPlatforms.tinyCountdownWidth
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: width, maximum: width))], alignment: .leading) {
            ForEach(cds) { countdown in
                Tiny(countdown)
            }
        }
    }
    
    func small(_ cds: [Countdown]) -> some View {
        ForEach(cds) { countdown in
            Small(countdown)
        }
    }
    
    func fullSize(_ cds: [Countdown], forcingExpired: Bool = false) -> some View {
        ForEach(cds) { countdown in
            FullSize(countdown, forcingExpired: forcingExpired)
        }
    }
    
    // Common
    @ViewBuilder
    func timeView(_ remainingTime: RemainingTimeDetails, _ timeSlicedMode: TimeSlicedMode, _ preferences: Preferences<DefaultUserPreferences>) -> some View {
        let separator = (timeSlicedMode == .small) ? Text(":") : Text(":").bold()
        
        if remainingTime.inSeconds >= 86400 {
            Text(remainingTime.d).timeSliced(timeSlicedMode)
            separator
        }
        
        if preferences.x.showZeroHourMinute || remainingTime.inSeconds >= 3600 || preferences.x.refreshTimerInterval >= K.refreshThresholdHideSeconds {
            Text(remainingTime.h).timeSliced(timeSlicedMode)
            separator
        }
        
        if preferences.x.showZeroHourMinute || remainingTime.inSeconds >= 60 || preferences.x.refreshTimerInterval >= K.refreshThresholdHideSeconds {
            Text(remainingTime.m).timeSliced(timeSlicedMode)
            if preferences.x.refreshTimerInterval < K.refreshThresholdHideSeconds {
                separator
            }
        }
        
        if preferences.x.refreshTimerInterval < K.refreshThresholdHideSeconds {
            Text(remainingTime.s).timeSliced(timeSlicedMode)
        }
    }
    
    // Conditional OS
    @ViewBuilder
    func scrollViewOnMac(_ title: String? = nil, content: () -> some View) -> some View {
        #if os(macOS)
        ScrollView {
            if let title {
                HStack {
                    Text(title).bold()
                    Spacer()
                }
                .padding(.bottom)
            }
            
            content()
        }
        #else
        content()
        #endif
    }
    
    func macOSDevider() -> some View {
        #if os(macOS)
        Divider().padding(.vertical)
        #else
        EmptyView()
        #endif
    }
    
    // Others
    func actionIconButton(_ sfsymbol: String, _ color: Color = .red, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: sfsymbol)
                .foregroundColor(color)
                #if os(iOS)
                .font(.title)
                #endif
        }
        .buttonStyle(.plain)
    }
    
    func whichIndication(_ remainingTime: RemainingTimeDetails, _ preferences: Preferences<DefaultUserPreferences>) -> WhichIndication {
        var which: WhichIndication = .first
        if remainingTime.inSeconds > preferences.x.firstCIRemainingSeconds && remainingTime.inSeconds > preferences.x.secondCIRemainingSeconds {
            return .neither
        }
        
        if (preferences.x.firstCIRemainingSeconds < preferences.x.secondCIRemainingSeconds && remainingTime.inSeconds > preferences.x.firstCIRemainingSeconds)
        || (preferences.x.firstCIRemainingSeconds > preferences.x.secondCIRemainingSeconds && remainingTime.inSeconds < preferences.x.secondCIRemainingSeconds)
        {
            which = .second
            if !preferences.x.secondCIEnabled {
                return .neither
            }
        } else if !preferences.x.firstCIEnabled {
            return .neither
        }
        
        return which
    }
    
    func getCountdownIndicationColor(remainingTime: RemainingTimeDetails, defaultColor: Color, opacity: Double, preferences: Preferences<DefaultUserPreferences>) -> Color {
        
        switch whichIndication(remainingTime, preferences) {
        case .first:
            return Color(preferences.x.firstCIColor.rawValue).opacity(opacity)
        case .second:
            return Color(preferences.x.secondCIColor.rawValue).opacity(opacity)
        case .neither:
            return defaultColor
        }
    }
}

