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
}
#endif
