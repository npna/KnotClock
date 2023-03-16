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
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
    @AppStorage(K.StorageKeys.overrideDay) private var overrideDay = ""
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        NSApplication.shared.setActivationPolicy(preferences.x.showDockIcon ? .regular : .accessory)
    }
    #endif
    
    func mainView(isInMenubar: Bool = false) -> some View {
        return MainView(isInMenubar: isInMenubar)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(countdowns)
            .applyColorScheme()
    }
    
    var body: some Scene {
        #if os(macOS)
        Window(K.appName, id: K.appName) {
            mainView()
                .frame(minWidth: K.FrameSizes.Mac.Main.minWidth, maxWidth: .infinity, minHeight: K.FrameSizes.Mac.Main.minHeight, maxHeight: .infinity)
        }
        .defaultSize(width: K.FrameSizes.Mac.Main.minWidth, height: K.FrameSizes.Mac.Main.minHeight)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(K.appName)") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey(
                                rawValue: "Copyright"
                            ): "© \(K.copyright.year) \(K.copyright.creator)"
                        ]
                    )
                }
            }
        }
        
        Settings {
            SettingsView().applyColorScheme()
                .frame(minWidth: K.FrameSizes.Mac.Settings.minWidth, maxWidth: .infinity, minHeight: K.FrameSizes.Mac.Settings.minHeight, maxHeight: .infinity)
        }.defaultSize(width: K.FrameSizes.Mac.Settings.minWidth, height: K.FrameSizes.Mac.Settings.minHeight)
        
        MenuBarExtra(isInserted: $preferences.x.showMenubarExtra) {
            mainView(isInMenubar: true)
                .frame(minWidth: K.FrameSizes.Mac.Menubar.minWidth)
        } label: {
            macMenubar.menubarIcon()
        }
        .menuBarExtraStyle(.window)
        #else
        WindowGroup { mainView() }
        #endif
    }
}
