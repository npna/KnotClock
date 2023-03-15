//
//  SettingsView.swift
//  KnotClock
//
//  Created by NA on 2/21/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(K.StorageKeys.enableDebugMode) private var enableDebugMode = false
    
    private enum Tabs: Hashable {
        case countdowns, indications, application, debug
    }
    
    var body: some View {
        TabView {
            CountdownsSettingsView()
                .tabItem {
                    Label("Countdowns", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tabs.countdowns)
            IndicationsSettingsView()
                .tabItem {
                    Label("Indications", systemImage: "paintbrush")
                }
                .tag(Tabs.indications)
            ApplicationSettingsView()
                .tabItem {
                    Label("Application", systemImage: "app.badge.checkmark")
                }
                .tag(Tabs.application)
            
            if enableDebugMode {
                DebugView()
                    .tabItem {
                        Label("Debug", systemImage: "ladybug")
                    }
                    .tag(Tabs.debug)
            }
        }
        .macOSPadding(20)
        #if os(macOS) || DEBUG
            .contextMenu {
                Menu("Advanced Settings") {
                    Button("\(enableDebugMode ? "Disable" : "Enable") Debug Mode") {
                        enableDebugMode.toggle()
                    }
                }
            }
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
