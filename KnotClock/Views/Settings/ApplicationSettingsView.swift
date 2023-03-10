//
//  ApplicationSettingsView.swift
//  KnotClock
//
//  Created by NA on 2/21/23.
//

import SwiftUI
#if os(macOS)
import ServiceManagement
#endif

struct ApplicationSettingsView: View {
    @AppStorage(K.userPreferencesKey) var preferences = Preferences(x: DefaultUserPreferences())

    @State private var showResetSettingsConfirmation = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        scrollViewOnMac {
            Form {
                #if os(macOS)
                Section {
                    Picker("Application Icon", selection: $preferences.x.showApplicationIn) {
                        ForEach(MacSAISettings.allCases) { saiChoice in
                            Text(saiChoice.rawValue).tag(saiChoice)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: preferences.x.showApplicationIn) { iconSettings in
                        switch iconSettings {
                        case .both:
                            preferences.x.showMenubarExtra = true
                            preferences.x.showDockIcon = true
                        case .dock:
                            preferences.x.showMenubarExtra = false
                            preferences.x.showDockIcon = true
                        case .menubar:
                            preferences.x.showMenubarExtra = true
                            preferences.x.showDockIcon = false
                        }
                        
                        if preferences.x.showDockIcon {
                            NSApp.setActivationPolicy(.regular)
                        } else {
                            NSApp.setActivationPolicy(.accessory)
                        }
                    }
                    
                    Picker("Menubar Settings", selection: $preferences.x.menubarIconSettings) {
                        ForEach(MacMenubarIconSettings.allCases) { menubarChoice in
                            HStack {
                                menubarSettingsOptionImage(choice: menubarChoice)
                                Text(menubarChoice.rawValue)
                            }.tag(menubarChoice)
                        }
                    }
                    .disabled(!preferences.x.showMenubarExtra)
                    
                    Toggle("Launch at login", isOn: $preferences.x.launchAtLogin)
                        .onChange(of: preferences.x.launchAtLogin) { enable in
                            let sma = SMAppService.mainApp
                            do {
                                if enable {
                                    if sma.status == .enabled {
                                        try? sma.unregister()
                                    }
                                    try sma.register()
                                } else {
                                    try sma.unregister()
                                }
                            } catch {
                                alertMessage = "Failed to add application to login items. Error: \(error)"
                                showAlert = true
                            }
                        }
                }
                .padding(.bottom)
                #endif
                
                Button("Reset All Settings") {
                    showResetSettingsConfirmation = true
                }
            }
            .confirmationDialog("Are you sure you want to reset settings?", isPresented: $showResetSettingsConfirmation) {
                Button("Reset Everything") {
                    preferences.resetAllTo(DefaultUserPreferences())
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK"){
                    alertMessage = ""
                }
            }
        }
    }
    
    @ViewBuilder
    func menubarSettingsOptionImage(choice: MacMenubarIconSettings) -> some View {
        switch choice {
        case .simpleIcon:
            Image(K.Assets.menubarSimpleIcon)
        case .coloredSymbol:
            Image(systemName: preferences.x.menubarIconColoredSymbolName)
        case .appIcon:
            Image(K.Assets.tinyAppIcon)
        case .coloredSymbolAndNextCountdown:
            Image(systemName: preferences.x.menubarIconColoredSymbolName)
        case .simpleIconAndNextCountdown:
            Image(K.Assets.menubarSimpleIcon)
        case .appIconAndNextCountdown:
            Image(K.Assets.tinyAppIcon)
        default:
            EmptyView()
        }
    }
}

struct ApplicationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationSettingsView()
    }
}
