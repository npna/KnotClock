//
//  KnotClockApp.swift
//  KnotClock
//
//  Created by NA on 2/19/23.
//

import SwiftUI

@main
struct KnotClockApp: App {
    @StateObject private var dataController = DataController.shared
    @StateObject private var countdowns = Countdowns.shared
    
    #if os(macOS)
    @StateObject private var macMenubar = MacMenubar()
    @AppStorage(K.userPreferencesKey) var preferences = Preferences(x: DefaultUserPreferences())
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        NSApplication.shared.setActivationPolicy(preferences.x.showDockIcon ? .regular : .accessory)
    }
    #endif
    
    var body: some Scene {
        let mainView = MainView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(countdowns)
        
        #if os(macOS)
        Window(K.appName, id: K.appName) {
            mainView
                .frame(minWidth: K.MacWindowSizes.Main.minWidth, maxWidth: .infinity, minHeight: K.MacWindowSizes.Main.minHeight, maxHeight: .infinity)
        }.defaultSize(width: K.MacWindowSizes.Main.minWidth, height: K.MacWindowSizes.Main.minHeight)
        
        Settings {
            SettingsView()
                .frame(minWidth: K.MacWindowSizes.Settings.minWidth, maxWidth: .infinity, minHeight: K.MacWindowSizes.Settings.minHeight, maxHeight: .infinity)
        }.defaultSize(width: K.MacWindowSizes.Settings.minWidth, height: K.MacWindowSizes.Settings.minHeight)
        
        MenuBarExtra(isInserted: $preferences.x.showMenubarExtra) {
            MainView(isInMenubar: true)
                .frame(minWidth: K.MacWindowSizes.Menubar.minWidth)
        } label: {
            macMenubar.menubarIcon()
        }
        .menuBarExtraStyle(.window)
        #else
        WindowGroup { mainView }
        #endif
    }
}
