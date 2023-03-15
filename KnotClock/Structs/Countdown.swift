//
//  Countdown.swift
//  KnotClock
//
//  Created by NA on 2/27/23.
//

import Foundation
import CoreData

struct Countdown: Identifiable, Equatable {
    typealias DHMS = (d: Int, h: Int, m: Int, s: Int)
    let id: UUID
    let title: String
    let category: CountdownCategory
    let time: Int
    var isForTomorrow: Bool = false
    var isHidden: Bool = false
    
    var entityName: String {
        (self.category == .daily) ? "Daily" : "Single"
    }
    
    var remainingTime: RemainingTimeDetails {
        let dhms = Countdown.secondsToDHMS(remainingSeconds)
        let formattedFullRemainingTime = formattedFullRemainingTime(dhms: dhms)
        
        if remainingSeconds < 0 {
            return ("00", "00", "00", "00", remainingSeconds, category, formattedFullRemainingTime)
        }
        
        let d = String(format: "%0\(dhms.d.numberOfDigits())d", dhms.d)
        let h = String(format: "%02d", dhms.h)
        let m = String(format: "%02d", dhms.m)
        let s = String(format: "%02d", dhms.s)
        
        return (d, h, m, s, remainingSeconds, category, formattedFullRemainingTime)
    }
    
    var remainingSeconds: Int {
        if isForTomorrow {
            return (86400 - Countdown.getTimeAsSeconds()) + time
        }
        
        switch category {
        case .daily:
            return time - Countdown.getTimeAsSeconds()
        case .single:
            return time - Int(Date().timeIntervalSince1970)
        }
    }
    
    func formattedFullRemainingTime(dhms: DHMS) -> String {
        let day = abs(dhms.d)
        let hour = abs(dhms.h)
        let minute = abs(dhms.m)
        let second = abs(dhms.s)
        
        var returnValue = ""
        
        if remainingSeconds >= 86400 || remainingSeconds <= -86400 {
            returnValue = String(format: "%0\(day.numberOfDigits())d:%02d:%02d:%02d", day, hour, minute, second)
        } else {
            returnValue = String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        
        if remainingSeconds < 0 {
            returnValue = "- \(returnValue)"
        }
        
        return returnValue
    }
    
    func getTruncatedTitle(limit: Int = 25) -> String {
        let truncateWith = "..."
        guard title.count > limit, (title.count - truncateWith.count) > 0 else { return title }
        return "\(title.prefix(limit - truncateWith.count))..."
    }
    
    static func getTimeAsSeconds(of date: Date = Date()) -> Int {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        return (hour * 3600) + (minute * 60) + second
    }
    
    static func secondsToDHMS(_ seconds: Int) -> DHMS {
        let d = Int(seconds / 86400)
        let secondsMinusDays = seconds - d * 86400
        
        let h24 = secondsMinusDays / 3600
        let h = (h24 == 24) ? 0 : h24
        let m = secondsMinusDays / 60 % 60
        let s = secondsMinusDays % 60
        
        return (d, h, m, s)
    }
    
    static func convertTimeAsSecondsToTimeAsTodayDate(_ timeAsSeconds: Int) -> Date? {
        let startingDate = Calendar.current.startOfDay(for: Date())
        return convertRemainingSecondsToDate(timeAsSeconds, startingDate: startingDate)
    }
    
    static func convertRemainingSecondsToDate(_ seconds: Int, startingDate: Date = Date()) -> Date? {
        let dhms = secondsToDHMS(seconds)
        
        var addTimeComponents = DateComponents()
        addTimeComponents.second = dhms.s
        addTimeComponents.minute = dhms.m
        addTimeComponents.hour = dhms.h
        addTimeComponents.day = dhms.d
        
        return Calendar.current.date(byAdding: addTimeComponents, to: startingDate)
    }
    
    static func ==(lhs: Countdown, rhs: Countdown) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Core Data
    func deleteExpiredSingleHideDaily(dontCheckRemainingSeconds: Bool = false) {
        if category == .daily {
            Countdowns.shared.hideDaily(id)
        } else {
            guard remainingSeconds < 0 || dontCheckRemainingSeconds else { return }
            delete()
        }
    }
    
    func delete(_ checkCategory: CountdownCategory? = nil) {
        if let checkCategory, checkCategory != self.category {
            return
        }
        
        do {
            try fetchAndDelete()
            Countdowns.shared.refetchAll()
        } catch {
            Alerts.show("An error occurred while deleting countdown")
        }
    }
    
    func fetchAndDelete() throws {
        let moc = DataController.context
        let fetch = try self.fetchFromDB()
        
        switch category {
        case .daily:
            if let result = fetch as? Daily {
                moc.delete(result)
                try saveMOC()
            }
        case .single:
            if let result = fetch as? Single {
                moc.delete(result)
                try saveMOC()
            }
        }
    }
    
    func fetchFromDB() throws -> NSFetchRequestResult? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        return try DataController.context.fetch(fetchRequest).first
    }
    
    func saveMOC() throws {
        try DataController.context.save()
    }
}

extension Int {
    func numberOfDigits() -> Int {
        String(abs(self)).count
    }
}
