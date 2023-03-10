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
        switch category {
        case .daily:
            return Int(time) - Countdown.getTimeAsSeconds()
        case .single:
            return Int(time) - Int(Date().timeIntervalSince1970)
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
    
    static func convertTimeAsSecondsToDate(_ seconds: Int) -> Date? {
        let dhms = secondsToDHMS(seconds)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        let (year, intMonth, intDay) = (dateComponents.year, dateComponents.month, dateComponents.day)
        
        guard let year, let intMonth, let intDay else { return nil }
        
        let month = String(format: "%02d", intMonth)
        let day = String(format: "%02d", intDay + dhms.d)
        let time = String(format: "%02d:%02d:%02d", dhms.h, dhms.m, dhms.s)
        let fullDateString = "\(year)-\(month)-\(day)T\(time)"
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: fullDateString)
    }
    
    static func ==(lhs: Countdown, rhs: Countdown) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Core Data
    func deleteExpiredSingleHideDaily() {
        if category == .daily {
            Countdowns.shared.hideDaily(id)
        } else {
            guard remainingSeconds < 0 else { return }
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
            Countdowns.shared.alertMessage = "An error occurred while deleting countdown"
            Countdowns.shared.showAlert = true
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
