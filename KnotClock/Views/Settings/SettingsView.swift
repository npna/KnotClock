//
//  SettingsView.swift
//  KnotClock
//
//  Created by NA on 2/21/23.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case countdowns, indications, application
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
        }
        #if os(macOS)
        .padding(20)
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
