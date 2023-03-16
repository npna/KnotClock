//
//  Countdowns.swift
//  KnotClock
//
//  Created by NA on 2/27/23.
//

import SwiftUI
import CoreData

class Countdowns: ObservableObject {
    static let shared = Countdowns()
    
    @Published private(set) var current: [Countdown] = []
    @Published private(set) var upcomming: [Countdown] = []
    @Published private(set) var expired: [Countdown] = []
    @Published private(set) var hidden: [Countdown] = []
    @Published private(set) var fullList: [Countdown] = []
    
    @Published private(set) var notIncludingTomorrowTodayOverridden: Bool = false
    
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
    @AppStorage(K.StorageKeys.hiddenDailies) private var hiddenDailies = HideDaily(list: [HiddenDailyItem()])
    @AppStorage(K.StorageKeys.fetchedTomorrowDailies) private var fetchedTomorrowDailies: Bool = false
    
    private let notifications = Notifications.shared
    private let dateHelper = DateHelper()
    
    private var timer: Timer? = nil
    private var oldTimerInterval: Double? = nil
    private var lastRefetchDay: Int = 0
    
    private init() {
        rescheduleTimer(interval: preferences.x.refreshTimerInterval)
    }
    
    func rescheduleTimer(interval: Double) {
        if let oldTimerInterval, oldTimerInterval == interval {
            return
        } else {
            oldTimerInterval = interval
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.updateViewTimes()
        }
    }
    
    func updateViewTimes(dontRefetch: Bool = false) {
        if updateViewShouldRefetch(dontRefetch) {
            refetchAll()
        }
        
        expired.removeAll()
        current.removeAll()
        upcomming.removeAll()
        hidden.removeAll()
        var lowestRemainingSeconds: Int? = nil
        
        let upMax = Int(preferences.x.maxUpcomming)
        let exMax = Int(preferences.x.maxExpired)
        
        var countUp = 0
        var countEx = 0
        
        let autoHideExpiredDailies = preferences.x.autoHideExpiredDailies
        let autoRemoveExpiredSingles = preferences.x.autoRemoveExpiredSingles
        
        for item in fullList {
            if item.remainingSeconds < 0
            {
                if countEx >= exMax {
                    continue
                }
                
                switch item.category {
                case .daily:
                    if autoHideExpiredDailies || isDailyHidden(item.id) {
                        continue
                    }
                case .single:
                    if autoRemoveExpiredSingles {
                        item.deleteExpiredSingleHideDaily()
                        continue
                    }
                }
                
                countEx += 1
                expired.append(item)
            }
            else if item.category == .daily && isDailyHidden(item.id) {
                hidden.append(Countdown(id: item.id, title: item.title, category: .daily, time: item.time, isHidden: true))
            }
            else if lowestRemainingSeconds == nil
            {
                lowestRemainingSeconds = item.remainingSeconds
                current.append(item)
            }
            else if item.remainingSeconds == lowestRemainingSeconds && current.count < 3
            {
                current.append(item)
            }
            else
            {
                if countUp >= upMax {
                    continue
                }
                
                countUp += 1
                upcomming.append(item)
            }
        }
    }
    
    func updateViewShouldRefetch(_ dontRefetch: Bool) -> Bool {
        let shouldRefetch = (dontRefetch == false && (lastRefetchDay != dateHelper.todayYMD() || shouldIncludeTomorrowDailies(inRangeOfRefreshTimerInterval: true)))
        #if DEBUG
        if lastRefetchDay != dateHelper.todayYMD() {
            print("Day has changed, refetched data.")
        } else if shouldRefetch {
            print("Time to include tomorrow's daily countdowns.")
        }
        #endif
        return shouldRefetch
    }
    
    func refetchAll(resetNotifs: Bool = false) {
        fullList.removeAll()
        
        let dailies = getDailies()
        let singles = getSingles()
        
        for daily in dailies {
            fullList.append(Countdown(id: daily.id ?? UUID(), title: daily.title ?? "", category: .daily, time: Int(daily.time)))
        }
        
        // For Tomorrow (based on preferences.x.includeTomorrowDailiesInTodaySecondsEarlier and if day isn't overridden)
        if let includeTomorrow = getDailiesForTomorrow() {
            for td in includeTomorrow {
                // Should set isForTomorrow: true
                fullList.append(Countdown(id: td.id ?? UUID(), title: td.title ?? "", category: .daily, time: Int(td.time), isForTomorrow: true))
            }
        }
        
        for single in singles {
            fullList.append(Countdown(id: single.id ?? UUID(), title: single.title ?? "", category: .single, time: Int(single.deadlineEpoch)))
        }
        
        fullList = Array(Set(fullList))
        
        fullList.sort { lhs, rhs in
            return lhs.remainingSeconds < rhs.remainingSeconds
        }
        
        lastRefetchDay = dateHelper.todayYMD()
        
        updateViewTimes(dontRefetch: true)
        
        if resetNotifs {
            notifications.reset(fullList: fullList)
        }
        
        #if DEBUG
        print("Refetched All")
        #endif
    }
    
    // TODO: Implement a better approach
    // without this MainView won't update after editing Single/Daily countdowns
    func refetchWithDelay(_ delay: TimeInterval = 0.5) {
        fullList.removeAll()
        updateViewTimes(dontRefetch: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.refetchAll(resetNotifs: true)
        }
    }
    
    func reset(level: CountdownResetLevel) {        
        switch level {
        case .updateViewTimes:
            updateViewTimes(dontRefetch: true)
            
        case .refetch:
            refetchAll()
            
        case .resetNotifs:
            notifications.reset(fullList: fullList)
            
        case .refetchResetNotifs:
            refetchAll(resetNotifs: true)
            
        case .refetchWithDelayResetNotifs:
            refetchWithDelay()
            
        case .reloadContainerRefetchResetNotifs:
            DataController.shared.reload()
            refetchWithDelay()
        }
    }
    
    func thereAreNoCountdowns() -> Bool {
        current.count == 0 && upcomming.count == 0 && expired.count == 0
    }
    
    func shouldIncludeTomorrowDailies(inRangeOfRefreshTimerInterval: Bool = false) -> Bool {
        let secondsEarlier = preferences.x.includeTomorrowDailiesInTodaySecondsEarlier
        
        guard secondsEarlier > 1 else {
            return false
        }
        
        let whenToIncludeTomorrow = 86400 - Double(secondsEarlier)
        let currenTimeAsSeconds = Double(Countdown.getTimeAsSeconds())
        
        if inRangeOfRefreshTimerInterval {
            let inUpperRange = whenToIncludeTomorrow < (currenTimeAsSeconds + preferences.x.refreshTimerInterval)
            
            if fetchedTomorrowDailies {
                if !inUpperRange {
                    fetchedTomorrowDailies = false
                }
                return false
            }
            
            if whenToIncludeTomorrow > (currenTimeAsSeconds - preferences.x.refreshTimerInterval)
            && inUpperRange
            {
                fetchedTomorrowDailies = true
                return true
            }
        } else if currenTimeAsSeconds >= whenToIncludeTomorrow {
            fetchedTomorrowDailies = true
            return true
        }
        
        return false
    }
    
    func getDailiesForTomorrow() -> [Daily]? {
        let weekdays = K.weekdays
        notIncludingTomorrowTodayOverridden = false
        
        if let _ = dateHelper.todayIsOverriddenAs() {
            if shouldIncludeTomorrowDailies() {
                notIncludingTomorrowTodayOverridden = true
            }
            return nil
        }
        
        guard shouldIncludeTomorrowDailies(),
              let currentIndex = weekdays.firstIndex(of: dateHelper.weekdayName(allowOverride: false))
        else {
            return nil
        }
        
        let nextIndex = (currentIndex + 1) % weekdays.count
        
        return getDailies(for: weekdays[nextIndex])
    }
    
    func getDailies(for day: String? = nil) -> [Daily] {
        var selectedDay = dateHelper.weekdayName(allowOverride: true)
        
        if let day, K.weekdays.contains(day.lowercased()) {
            selectedDay = day
        }
        
        let predicate = NSPredicate(format: "\(selectedDay.lowercased()) == %@", NSNumber(value: true))

        let results = fetch(entityName: "Daily", predicate: predicate, sortBy: "time")
        return (results as? [Daily]) ?? []
    }
    
    func getSingles(fetchLimit: Int? = nil, excludeExpired: Bool = false, limitByMaxEpoch: Bool = true, ascendingOrder: Bool = true) -> [Single] {
        var predicate: NSPredicate? = nil
        var format: String? = nil
        
        let now = Int(Date().timeIntervalSince1970)
        let includeSingleCountdownsInListSecondsEarlier = preferences.x.includeSingleCountdownsInListSecondsEarlier
        let maxEpoch = now + includeSingleCountdownsInListSecondsEarlier
        
        if limitByMaxEpoch && excludeExpired && includeSingleCountdownsInListSecondsEarlier != -1 {
            format = "deadlineEpoch <= \(maxEpoch) && deadlineEpoch >= \(now)"
        } else if limitByMaxEpoch && includeSingleCountdownsInListSecondsEarlier != -1 {
            format = "deadlineEpoch <= \(maxEpoch)"
        } else if excludeExpired {
            format = "deadlineEpoch >= \(now)"
        }
        
        if let format {
            predicate = NSPredicate(format: format)
        }
        
        let results = fetch(entityName: "Single", predicate: predicate, sortBy: "deadlineEpoch", ascending: ascendingOrder, limit: fetchLimit)
        return (results as? [Single]) ?? []
    }
    
    func getSingle(id: UUID) -> Single? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = fetch(entityName: "Single", predicate: predicate)
        
        if let singles = result as? [Single], singles.count > 0 {
            return singles.first
        }
        
        return nil
    }
    
    func fetch(entityName: String, predicate: NSPredicate?, sortBy: String? = nil, ascending: Bool = true, limit: Int? = nil) -> [NSFetchRequestResult] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        if let predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortBy {
            let sortDescriptor = NSSortDescriptor(key: sortBy, ascending: ascending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        if let limit {
            fetchRequest.fetchLimit = limit
        }
        
        do {
            let results = try DataController.sharedContext.fetch(fetchRequest)
            return results
        } catch {
            #if DEBUG
            print(error)
            #endif
            return []
        }
    }
    
    func hideDaily(_ id: UUID) {
        if Int.random(in: 1...10) == 1 {
            clearOldHiddenDaily()
        }
        hiddenDailies.list.append(HiddenDailyItem(id: id, ymd: dateHelper.todayYMD()))
        refetchAll()
    }
    
    func unhideDaily(_ id: UUID) {
        hiddenDailies.list.removeAll(where: { $0.id == id })
        refetchAll()
    }
    
    func isDailyHidden(_ id: UUID?) -> Bool {
        if let _ = hiddenDailies.list.firstIndex(where: { $0.id == id && $0.ymd == dateHelper.todayYMD() }) {
            return true
        }
        return false
    }
    
    func clearOldHiddenDaily() {
        hiddenDailies.list.removeAll(where: { $0.ymd < dateHelper.todayYMD() })
    }
}
