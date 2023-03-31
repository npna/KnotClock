//
//  AppDelegate.swift
//  KnotClock
//
//  Created by NA on 3/2/23.
//

#if os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let showDock = UserDefaults.standard.object(forKey: K.StorageKeys.userPreferences) as? String,
           let decoded = try? JSONDecoder().decode(DefaultUserPreferences.self, from: Data(showDock.utf8)),
           let window = NSApp.windows.first,
           decoded.showDockIcon == false
        {
            window.close()
        }
    }
}
#endif
