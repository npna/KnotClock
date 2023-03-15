//
//  OverviewDailyCountdownsTableCellWithAction.swift
//  KnotClock
//
//  Created by NA on 3/1/23.
//

import SwiftUI

struct OverviewDailyCountdownTableCellWithAction: View {
    let dailyCountdown: Daily
    let weekday: String
    
    @Environment(\.managedObjectContext) var moc
    @State private var showingDeleteConfirmation = false
    @State private var showingEditPopover = false
    
    @State private var title: String
    @State private var dailyTime: Date
    @State private var validTime: Bool = true
    @State private var days = K.weekdaysForSelection
    
    init(dailyCountdown: Daily, weekday: String) {
        self.dailyCountdown = dailyCountdown
        self.weekday = weekday
        
        _title = State(initialValue: dailyCountdown.title ?? "")
        if let timeAsDate = Countdown.convertTimeAsSecondsToTimeAsTodayDate(Int(dailyCountdown.time)) {
            _dailyTime = State(initialValue: timeAsDate)
        } else {
            #if DEBUG
            print("Invalid dailyTime!")
            #endif
            _dailyTime = State(initialValue: Date())
            validTime = false
        }
        
        var tempDays: [(name: String, isSelected: Bool)] = []
        for day in days {
            let isSelected: Bool = (dailyCountdown.value(forKey: day.name.lowercased()) as? Bool) ?? false
            tempDays.append((name: day.name, isSelected: isSelected))
        }
        
        _days = State(initialValue: tempDays)
    }
    
    var body: some View {
        let dhms = Countdown.secondsToDHMS(Int(dailyCountdown.time))
        
        Divider().background(K.WeeklyOverview.borderColor)
        
        VStack(alignment: .leading) {
            HStack {
                Text(dailyCountdown.title ?? "").bold().frame(maxWidth: 190).fixedSize(horizontal: true, vertical: false)
                
                actionIconButton("pencil.circle.fill", .blue) {
                    showingEditPopover = true
                }
                
                actionIconButton("x.circle.fill") {
                    showingDeleteConfirmation = true
                }
            }
            .confirmationDialog("Deleting: \(title)", isPresented: $showingDeleteConfirmation) {
                Button("Detach from \(weekday.capitalized)", role: .destructive, action: detachFromWeekday)
                Button("Delete Completely", role: .destructive, action: deleteCompletely)
                Button("Cancel", role: .cancel) {
                    showingDeleteConfirmation = false
                }
            }
            .popover(isPresented: $showingEditPopover) {
                Text("Edit this countdown for all attached days:").bold().padding(.horizontal).padding(.top)
                Form {
                    TextField("Title", text: $title)
                    
                    if validTime {
                        DatePicker("Time", selection: $dailyTime, displayedComponents: .hourAndMinute)
                    }
                    
                    ForEach(days, id: \.name) { day, _ in
                        let binding = Binding<Bool>(
                            get: { days.first(where: { $0.name == day })?.isSelected ?? false },
                            set: { days[days.firstIndex(where: { $0.name == day })!].isSelected = $0 }
                        )
                        Toggle(day, isOn: binding)
                    }
                    
                    HStack(alignment: .center) {
                        Button("Save", action: saveEdits)
                            .buttonStyle(FormButton())
                        Button("Cancel", role: .cancel) { showingEditPopover = false }
                            .buttonStyle(FormButton(backgroundColor: .gray))
                    }
                    .padding(.top)
                }
                .padding()
            }
            
            Text(String(format: "%02d:%02d", dhms.h, dhms.m)).font(.footnote)
        }
        .frame(maxWidth: 240, alignment: .leading)
        .padding(.horizontal)
    }
    
    func saveEdits() {
        dailyCountdown.setValue(title, forKey: "title")
        if validTime {
            let time = Countdown.getTimeAsSeconds(of: dailyTime)
            dailyCountdown.setValue(time, forKey: "time")
        }
        
        for day in days {
            dailyCountdown.setValue(day.isSelected, forKey: day.name.lowercased())
        }
        
        showingEditPopover = false
        saveMOC()
    }
    
    func detachFromWeekday() {
        var count = 0
        for day in K.weekdays {
            let isAttached = dailyCountdown.value(forKey: day) as? Bool
            if isAttached == true {
                count += 1
            }
        }
        
        if count > 1 {
            dailyCountdown.setValue(false, forKey: weekday)
            saveMOC()
        } else { // If countdown is not attached to any other day, delete it completely
            deleteCompletely()
        }
    }
    
    func deleteCompletely() {
        moc.delete(dailyCountdown)
        saveMOC()
    }
    
    func saveMOC() {
        do {
            try moc.save()
            Countdowns.shared.reset(level: .refetchResetNotifs)
        } catch {
            Countdowns.shared.alertMessage = error.localizedDescription
            Countdowns.shared.showAlert = true
        }
    }
}
