//
//  DateHelper.swift
//  KnotClock
//
//  Created by NA on 3/15/23.
//

import SwiftUI

class DateHelper {
    @AppStorage(K.StorageKeys.overrideDay) private var overrideDay = ""
    
    func getCurrent(withFomat: String = K.dateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = K.dateFormat
        return dateFormatter.string(from: Date())
    }
    
    func overrideToday(as weekday: String) {
        overrideDay = "\(getCurrent())=\(weekday.lowercased())"
        
        Countdowns.shared.reset(level: .refetchResetNotifs)
    }
    
    func todayIsOverriddenAs() -> String? {
        let separated = overrideDay.components(separatedBy: "=")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = K.dateFormat
        
        if dateFormatter.string(from: Date()) == separated[0] && K.weekdays.contains(separated[1]) && weekdayName(allowOverride: false) != separated[1] {
            return separated[1]
        }
        
        return nil
    }
    
    func weekdayName(allowOverride: Bool) -> String {
        if allowOverride, let overridden = todayIsOverriddenAs() {
            return overridden
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: Date()).lowercased()
        }
    }
    
    func todayYMD() -> Int {
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "yyyyMMdd"
        return Int(dateFromatter.string(from: Date())) ?? 0
    }
}
