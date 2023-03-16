//
//  CountdownsSettingsView.swift
//  KnotClock
//
//  Created by NA on 2/21/23.
//

import SwiftUI

struct CountdownsSettingsView: View {
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
    
    private var needsRefetch: [String] {[
        preferences.x.autoHideExpiredDailies.description,
        preferences.x.autoRemoveExpiredSingles.description,
        preferences.x.maxUpcomming.description,
        preferences.x.maxExpired.description,
        preferences.x.includeSingleCountdownsInListSecondsEarlier.description,
        preferences.x.includeTomorrowDailiesInTodaySecondsEarlier.description
    ]}
    
    var body: some View {
        scrollViewOnMac {
            Form {
                Section("Current Countdown(s)") {
                    Picker("List Type", selection: $preferences.x.currentCountdownStyle) {
                        ForEach(UpcommingAndExpiredSettings.allCases) { setting in
                            if [.tiny,.small,.fullSize].contains(setting) {
                                Text(setting.rawValue).tag(setting)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("There might be multiple current countdowns if they have the same expiring time.").font(.footnote)
                }
                
                macOSDevider()
                
                Section("Upcomming Countdowns") {
                    Picker("List Type", selection: $preferences.x.upcommingCountdownStyle) {
                        ForEach(UpcommingAndExpiredSettings.allCases) { setting in
                            Text(setting.rawValue).tag(setting)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Slider(value: $preferences.x.maxUpcomming, in: K.minUpExSliderValue...K.maxUpExSliderValue, step: 1) {
                        Text("Max. visible")
                    } minimumValueLabel: {
                        Text("\(K.minUpExSliderValue.formatted())")
                    } maximumValueLabel: {
                        Text("\(K.maxUpExSliderValue.formatted())")
                    }
                    .disabled(preferences.x.upcommingCountdownStyle == .hide)
                }
                
                macOSDevider()
                
                Section("Expired Countdowns") {
                    Picker("List Type", selection: $preferences.x.expiredCountdownStyle) {
                        ForEach(UpcommingAndExpiredSettings.allCases) { setting in
                            Text(setting.rawValue).tag(setting)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Slider(value: $preferences.x.maxExpired, in: K.minUpExSliderValue...K.maxUpExSliderValue, step: 1) {
                        Text("Max. visible")
                    } minimumValueLabel: {
                        Text("\(K.minUpExSliderValue.formatted())")
                    } maximumValueLabel: {
                        Text("\(K.maxUpExSliderValue.formatted())")
                    }
                    .disabled(preferences.x.expiredCountdownStyle == .hide)
                    
                    Toggle("Auto-hide Expired Daily Countdowns", isOn: $preferences.x.autoHideExpiredDailies)
                    Toggle("Auto-remove Expired Single Countdowns", isOn: $preferences.x.autoRemoveExpiredSingles)
                }
                
                macOSDevider()
                
                Section() {
                    Text("When to include Single Countdowns in the upcomming list?")
                    Picker("", selection: $preferences.x.includeSingleCountdownsInListSecondsEarlier) {
                        Text("1 hour earlier").tag(3600 * 1)
                        Text("6 hours earlier").tag(3600 * 6)
                        Text("12 hours earlier").tag(3600 * 12)
                        Text("1 day earlier").tag(86400 * 1)
                        Text("2 days earlier").tag(86400 * 2)
                        Text("3 days earlier").tag(86400 * 3)
                        Text("7 days earlier").tag(86400 * 7)
                        Text("30 days earlier").tag(86400 * 30)
                        Text("Always").tag(-1)
                    }
                    
                    Text("How much earlier to include tomorrow's daily countdowns")
                    Picker("", selection: $preferences.x.includeTomorrowDailiesInTodaySecondsEarlier) {
                        Text("Never (only after the day changes)").tag(0)
                        Text("30 minutes before the day ends").tag(1800)
                        Text("1 hour before the day ends").tag(3600 * 1)
                        Text("2 hours before the day ends").tag(3600 * 2)
                        Text("6 hours before the day ends").tag(3600 * 6)
                        Text("12 hours before the day ends").tag(3600 * 12)
                        Text("Always (show today and tomorrow)").tag(3600 * 24)
                    }
                }
            }
            .onChange(of: needsRefetch) { _ in
                Countdowns.shared.reset(level: .refetch)
            }
        }
    }
}

struct CountdownsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownsSettingsView()
    }
}
