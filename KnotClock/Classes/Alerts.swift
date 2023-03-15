//
//  Alerts.swift
//  KnotClock
//
//  Created by NA on 3/15/23.
//

import Foundation

class Alerts: ObservableObject {
    static let shared = Alerts()
    
    @Published var message = ""
    @Published var isPresented = false
    
    static func show(_ message: String) {
        Alerts.shared.message = message
        Alerts.shared.isPresented = true
    }
}
