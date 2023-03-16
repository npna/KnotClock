//
//  Notifications.swift
//  KnotClock
//
//  Created by NA on 3/15/23.
//

import SwiftUI
import UserNotifications

class Notifications: ObservableObject {
    static let shared = Notifications()
    
    private init() {}
    
    @Published private(set) var totalCount = 0
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
    
    func reset(fullList: [Countdown]) {
        guard preferences.x.notificationCenterAuthorized == true else { return }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        totalCount = 0
        
        if countForCurrentSettings(fullList: fullList, withAlert: true) >= K.notificationsLimit {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.2) {
            self.addAllWithoutChecks(fullList)
        }
    }
    
    func addAllWithoutChecks(_ countdowns: [Countdown]) {
        for countdown in countdowns {
            if preferences.x.firstCIEnabled && preferences.x.notificationOnFirstIndication {
                let firstIndicationSeconds = TimeInterval(countdown.remainingSeconds - preferences.x.firstCIRemainingSeconds)
                add(countdown: countdown, willReach: "First Indication", inSeconds: firstIndicationSeconds)
            }
            
            if preferences.x.secondCIEnabled && preferences.x.notificationOnSecondIndication {
                let secondIndicationSeconds = TimeInterval(countdown.remainingSeconds - preferences.x.secondCIRemainingSeconds)
                add(countdown: countdown, willReach: "Second Indication", inSeconds: secondIndicationSeconds)
            }
            
            if preferences.x.notificationOnCountdownHitsZero {
                add(countdown: countdown, willReach: "Zero", inSeconds: TimeInterval(countdown.remainingSeconds))
            }
        }
        
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
                DispatchQueue.main.async {
                    print("Pending Notifications: \(requests.count)")
                }
            })
        }
        #endif
    }
    
    func countForCurrentSettings(fullList: [Countdown], withAlert: Bool = false) -> Int {
        var count = 0
        
        for _ in fullList {
            if preferences.x.firstCIEnabled && preferences.x.notificationOnFirstIndication { count += 1 }
            if preferences.x.secondCIEnabled && preferences.x.notificationOnSecondIndication { count += 1 }
            if preferences.x.notificationOnCountdownHitsZero { count += 1 }
        }
        
        if K.notificationsLimit > 0 && withAlert && count >= K.notificationsLimit {
            Alerts.show("With current settings there will be \(count) notifications which exceeds system limit, please adjust the settings. For now notifications are disabled.")
        }
        
        totalCount = count
        
        return count
    }
    
    func add(countdown: Countdown, willReach: String, inSeconds: TimeInterval, repeatDailyCountdown: Bool = false) {
        guard inSeconds > 0 else { return }
        
        let repeating = (countdown.category == .daily && repeatDailyCountdown) ? true : false
        
        let uniqueString = "\(countdown.id.uuidString)-\(willReach.replacingOccurrences(of: " ", with: ""))"
        let content = UNMutableNotificationContent()
        content.title = countdown.title
        content.body = "\(countdown.title) has reached \(willReach)"
        content.sound = .default
        
        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + inSeconds)
        
        var attachedComponents: Set<Calendar.Component> = [.weekday, .hour, .minute, .second]
        if repeating {
            attachedComponents = [.hour, .minute, .second]
        }
        let dateComponents = Calendar.current.dateComponents(attachedComponents, from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeating)
        let request = UNNotificationRequest(identifier: uniqueString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error {
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
    }
}
