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
    static let sharedContext = DataController.shared.container.viewContext
    
    private(set) var container = NSPersistentContainer(name: K.appName)
    
    init() {
        load()
    }
    
    func reload() {
        container = NSPersistentContainer(name: K.appName)
        load()
    }
    
    func load() {
        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Error when loading CoreData: \(error.localizedDescription)")
            }
        }
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


// MARK: - DEBUG
extension DataController {
    func clearEntireCoreData(confirm: Bool, reset: Bool = true) {
        guard confirm else { return }
        let coreDataEntities = DataController.shared.container.managedObjectModel.entities.map({ $0.name })
        
        coreDataEntities.forEach { [weak self] entityName in
            if let entityName {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
                
                do {
                    #if DEBUG
                    print("Clearing \(entityName) in Core Data")
                    #endif
                    try self?.container.viewContext.execute(deleteRequest)
                    try self?.container.viewContext.save()
                } catch {
                    Alerts.show("Error clearing CoerData (\(entityName)): \(error)")
                }
            }
        }
        
        if reset {
            Countdowns.shared.reset(level: .reloadContainerRefetchResetNotifs)
        }
    }
    
    func clearAndFillWithRandomData(confirm: Bool, countdownsTotal: Int = 20) {
        guard confirm else { return }
        clearEntireCoreData(confirm: confirm, reset: false)
        
        let (dailyTimes, singleTimes) = randomTimes(countdownsTotal)
        
        #if DEBUG
        print("Inserting \(dailyTimes.count) daily and \(singleTimes.count) single random countdowns.")
        #endif
        
        for i in 1...dailyTimes.count {
            let title: String = "Daily Countdown #\(i)"
            
            let dailyCountdown = Daily(context: container.viewContext)
            dailyCountdown.id = UUID()
            dailyCountdown.title = title
            dailyCountdown.time = dailyTimes[i-1]
            K.weekdays.forEach { day in
                dailyCountdown.setValue(Bool.random(), forKey: day.lowercased())
            }
            
            try? container.viewContext.save()
        }
        
        for i in 1...singleTimes.count {
            let title: String = "Single Countdown #\(i)"
            
            let singleCountdown = Single(context: container.viewContext)
            singleCountdown.id = UUID()
            singleCountdown.title = title
            singleCountdown.deadlineEpoch = singleTimes[i-1]
            
            try? container.viewContext.save()
        }
        
        Countdowns.shared.reset(level: .reloadContainerRefetchResetNotifs)
    }
    
    func randomTimes(_ total: Int) -> (daily: [Int32], single: [Int64]) {
        let singleCount = total / 5
        let dailyCount = total - singleCount
        
        var dailyTimes: [Int32] = []
        for _ in 1...dailyCount {
            let randomTime = (Int32.random(in: 0...86400) / 60) * 60
            dailyTimes.append(randomTime)
        }
        dailyTimes.sort()
        
        var singleDeadlineEpoches: [Int64] = []
        for _ in 1...singleCount {
            let randomEpoch = ((Int64(Date().timeIntervalSince1970) + Int64.random(in: 10...172800)) / 60) * 60
            singleDeadlineEpoches.append(randomEpoch)
        }
        singleDeadlineEpoches.sort()
        
        return (dailyTimes, singleDeadlineEpoches)
    }
}
