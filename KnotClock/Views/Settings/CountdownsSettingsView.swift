//
//  CountdownsSettingsView.swift
//  KnotClock
//
//  Created by NA on 2/21/23.
//

import SwiftUI

struct CountdownsSettingsView: View {
    @AppStorage(K.userPreferencesKey) var preferences = Preferences(x: DefaultUserPreferences())
    
    var body: some View {
        scrollViewOnMac {
            Form {
                Group {
                    Section {
                        Picker("Timer Accuracy", selection: $preferences.x.refreshTimerInterval) {
                            ForEach(K.timerAccuracyOptions, id: \.1) { (title, time) in
                                let hidesSeconds = (time >= K.refreshThresholdHideSeconds) ? " - Hides seconds" : ""
                                Text("\(title) (~\(time.formatted()) seconds)\(hidesSeconds)").tag(time)
                            }
                        }
                        Text("Timers \(K.refreshThresholdHideSeconds.formatted()) and above hide \"seconds\" part in countdown.").font(.footnote)
                        Text("Higher accuracy consumes more power.").font(.footnote)
                    }
                    
                    Toggle("Show Hour and Minute after they reach zero", isOn: $preferences.x.showZeroHourMinute)
                        .disabled(preferences.x.refreshTimerInterval >= K.refreshThresholdHideSeconds)
                    
                    if preferences.x.refreshTimerInterval >= K.refreshThresholdHideSeconds {
                        Text("This option is disabled when Timer is \(K.refreshThresholdHideSeconds.formatted())+ seconds.").font(.footnote)
                    }
                    
                    macOSDevider()
                }
                
                Group {
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
                }
                
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
                    .onChange(of: preferences.x.includeSingleCountdownsInListSecondsEarlier) { _ in
                        Countdowns.shared.refetchAll()
                    }
                }
            }
        }
    }
}

struct CountdownsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownsSettingsView()
    }
}
