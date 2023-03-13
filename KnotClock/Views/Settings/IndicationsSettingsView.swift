//
//  IndicationsSettingsView.swift
//  KnotClock
//
//  Created by NA on 3/4/23.
//

import SwiftUI
import UserNotifications

struct IndicationsSettingsView: View {
    @StateObject private var countdowns = Countdowns.shared
    @AppStorage(K.StorageKeys.userPreferences) var preferences = Preferences(x: DefaultUserPreferences())
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    @State private var timer: Timer? = nil
    
    private var notificationNeedsUpdate: [String] {[
        preferences.x.firstCIEnabled.description,
        preferences.x.firstCIRemainingSeconds.description,
        preferences.x.secondCIEnabled.description,
        preferences.x.secondCIRemainingSeconds.description,
        preferences.x.notificationCenterAuthorized.description,
        preferences.x.notificationOnFirstIndication.description,
        preferences.x.notificationOnSecondIndication.description,
        preferences.x.notificationOnCountdownHitsZero.description
    ]}
    
    var body: some View {
        scrollViewOnMac {
            Form {
                Section("First Indication") {
                    Toggle("Enable", isOn: $preferences.x.firstCIEnabled.animation())
                    VStack {
                        HStack {
                            TextField("Limit (Seconds)", value: $preferences.x.firstCIRemainingSeconds, format: .number)
                                .onChange(of: preferences.x.firstCIRemainingSeconds) { newValue in
                                    if newValue < preferences.x.ciRemainingSecondsMinValue {
                                        preferences.x.firstCIRemainingSeconds = preferences.x.ciRemainingSecondsMinValue
                                    }
                                    if newValue > preferences.x.ciRemainingSecondsMaxValue {
                                        preferences.x.firstCIRemainingSeconds = preferences.x.ciRemainingSecondsMaxValue
                                    }
                                }
                            Text(remainingCITime(seconds: preferences.x.firstCIRemainingSeconds))
                        }
                        HStack {
                            Picker("Indication Color", selection: $preferences.x.firstCIColor) {
                                ForEach(ColorSets.allCases) { color in
                                    Text(color.rawValue.replacingOccurrences(of: "App", with: "")).tag(color)
                                }
                            }
                            RoundedRectangle(cornerRadius: 3).fill(Color(preferences.x.firstCIColor.rawValue)).frame(width: 16, height: 16)
                        }
                    }
                    .disabled(!preferences.x.firstCIEnabled)
                    
                    notificationToggle(for: $preferences.x.notificationOnFirstIndication).disabled(!preferences.x.firstCIEnabled)
                }
                
                macOSDevider()
                
                Section("Second Indication") {
                    Toggle("Enable", isOn: $preferences.x.secondCIEnabled.animation())
                    VStack {
                        HStack {
                            TextField("Limit (Seconds)", value: $preferences.x.secondCIRemainingSeconds, format: .number)
                                .onChange(of: preferences.x.secondCIRemainingSeconds) { newValue in
                                    if newValue < preferences.x.ciRemainingSecondsMinValue {
                                        preferences.x.secondCIRemainingSeconds = preferences.x.ciRemainingSecondsMinValue
                                    }
                                    if newValue > preferences.x.ciRemainingSecondsMaxValue {
                                        preferences.x.secondCIRemainingSeconds = preferences.x.ciRemainingSecondsMaxValue
                                    }
                                }
                            Text(remainingCITime(seconds: preferences.x.secondCIRemainingSeconds))
                        }
                        HStack {
                            Picker("Indication Color", selection: $preferences.x.secondCIColor) {
                                ForEach(ColorSets.allCases) { color in
                                    Text(color.rawValue.replacingOccurrences(of: "App", with: "")).tag(color)
                                }
                            }
                            RoundedRectangle(cornerRadius: 3).fill(Color(preferences.x.secondCIColor.rawValue)).frame(width: 16, height: 16)
                        }
                    }
                    .disabled(!preferences.x.secondCIEnabled)
                    
                    notificationToggle(for: $preferences.x.notificationOnSecondIndication).disabled(!preferences.x.secondCIEnabled)
                }
                
                macOSDevider()
                
                Section("When the countdown hits zero") {
                    notificationToggle(for: $preferences.x.notificationOnCountdownHitsZero)
                }
                
                if preferences.x.notificationCenterAuthorized {
                    Group {
                        Text("Please note there is a limit of 64 for total notifications,")
                        Text("so adjust settings accordingly to avoid reaching that limit.")
                        Text("Total notification for today: \(countdowns.notificationsTotalCount)").bold().padding(.vertical)
                    }
                    .font(.footnote)
                }
            }
            .onChange(of: notificationNeedsUpdate, perform: { newValue in
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    #if DEBUG
                    print("Resetting Notifications")
                    #endif
                    countdowns.resetNotifications()
                }
            })
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK"){}
            }
            .onAppear {
                checkIfNotificationCenterAuthorized()
            }
        }
    }
    
    @ViewBuilder
    func notificationToggle(for situation: Binding<Bool>) -> some View {
        if preferences.x.notificationCenterAuthorized {
            Toggle("Notification", isOn: situation)
        } else {
            Button("Enable Notifications", action: requestUserNotificationPermission)
        }
    }
    
    func checkIfNotificationCenterAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.preferences.x.notificationCenterAuthorized = true
            default:
                self.preferences.x.notificationCenterAuthorized = false
            }
        })
    }
    
    func requestUserNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                self.preferences.x.notificationCenterAuthorized = true
            } else if let error = error {
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
    
    func remainingCITime(seconds: Int) -> String {
        let dhms = Countdown.secondsToDHMS(seconds)
        var remainingCITime = ""
        
        remainingCITime += (dhms.h > 0) ? "\(dhms.h)h " : ""
        remainingCITime += (dhms.m > 0) ? "\(dhms.m)m " : ""
        remainingCITime += (dhms.s > 0) ? "\(dhms.s)s " : ""
        
        return remainingCITime
    }
}

struct IndicationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        IndicationsSettingsView()
    }
}
