//
//  DataController.swift
//  KnotClock
//
//  Created by NA on 2/19/23.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()
    static let context = DataController.shared.container.viewContext
    let container = NSPersistentContainer(name: K.appName)
    
    init() {
        load()
    }
    
    func load() {
        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Error when loading CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    func reload() {
        load()
    }
}

extension Daily {
    var forEachID: String {
        if let uuidString = self.id?.uuidString, let title = self.title {
            return "\(uuidString)\(title)\(self.time)"
        } else {
            #if DEBUG
            print("Invalid UUID or Title: \(self.id?.uuidString ?? "") , \(self.title ?? "")")
            #endif
            return "Invalid UUID"
        }
    }
}

extension Single {
    var remainingSecondsToDeadline: Int {
        let now = Date().timeIntervalSince1970
        return Int(self.deadlineEpoch) - Int(now)
    }
    
    var deadlineDate: Date? {
        if self.remainingSecondsToDeadline < 0 {
            return nil
        }
        
        return Countdown.convertRemainingSecondsToDate(self.remainingSecondsToDeadline)
    }
}
