//
//  AddCountdownView.swift
//  KnotClock
//
//  Created by NA on 2/22/23.
//

import SwiftUI

struct AddCountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: String
    @State private var title = ""
    @State private var dailyTime = Date()
    @State private var singleTime = Date()
    @State private var days = K.weekdaysForSelection
    @State private var alertIsPresented = false
    @State private var alertMessage = ""
    
    private let moc = DataController.context
    private var isInMenubar: Bool
    
    init(isInMenubar: Bool = false) {
        self.isInMenubar = isInMenubar
        
        if isInMenubar {
            self._selectedTab = State(initialValue: "Single")
        } else {
            self._selectedTab = State(initialValue: "Daily")
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                daily
                    .tabItem {
                        Label("Daily", systemImage: "list.dash")
                    }
                    .tag("Daily")
                
                single
                    .tabItem {
                        Label("Single", systemImage: "square.and.pencil")
                    }
                    .tag("Single")
            }
            .macOSPadding(.top)
        }
        .alert(alertMessage, isPresented: $alertIsPresented) {
            Button("OK"){}
        }
    }
    
    var daily: some View {
        Form {
            Section("Title and Time") {
                TextField("Title", text: $title)
                
                HStack {
                    DatePicker("Time", selection: $dailyTime, displayedComponents: .hourAndMinute)
                    #if os(macOS)
                        .overlay {
                            DatePicker("", selection: $dailyTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .scaledToFit()
                                .scaleEffect(0.35)
                                .offset(x:-70,y:-3)
                        }
                    #endif
                }
            }
            
            Section("Attach To") {
                ForEach(days, id: \.name) { day, _ in
                    let binding = Binding<Bool>(
                        get: { days.first(where: { $0.name == day })?.isSelected ?? false },
                        set: { days[days.firstIndex(where: { $0.name == day })!].isSelected = $0 }
                    )
                    Toggle(day, isOn: binding)
                }
            }
            
            formButtons
        }
        .formStyle(.grouped)
        .onSubmit {
            submitForm()
        }
        
    }
    
    var single: some View {
        Form {
            Section("Title and Time") {
                TextField("Title", text: $title)
                
                HStack {
                    DatePicker("Time", selection: $singleTime)
                }
            }
            
            formButtons
        }
        .formStyle(.grouped)
        .onSubmit {
            submitForm()
        }
    }
    
    func submitForm() {
        if validateInputs() != true {
            return
        }
        
        if selectedTab == "Daily" { // Daily Countdown
            let dailyCountdown = Daily(context: moc)
            dailyCountdown.id = UUID()
            dailyCountdown.title = title
            
            dailyCountdown.time = Int32(Countdown.getTimeAsSeconds(of: dailyTime.omittingSecondsToZero ?? dailyTime))
            
            days.forEach { day, isSelected in
                dailyCountdown.setValue(isSelected, forKey: day.lowercased())
            }
        } else if selectedTab == "Single" { // Single Countdown
            let singleCountdown = Single(context: moc)
            singleCountdown.id = UUID()
            singleCountdown.title = title
            
            singleCountdown.deadlineEpoch = Int64((singleTime.omittingSecondsToZero ?? singleTime).timeIntervalSince1970)
        }
        
        do {
            try moc.save()
            Countdowns.shared.refetchAllAndHandleNotifications()
            dismiss()
        } catch {
            moc.reset()
            showAlert("Failed to add Countdown: \(error.localizedDescription)")
        }
    }
    
    func validateInputs() -> Bool {
        var isValid = true
        
        if isValid && title.isEmpty {
            isValid = false
            showAlert("Title is required.")
        }
        
        if isValid && selectedTab == "Daily" {
            var isAttached = false
            
            days.forEach { _, isSelected in
                if isSelected {
                    isAttached = true
                }
            }
            
            if isAttached == false {
                isValid = false
                showAlert("Please attach the countdown to one or more days.")
            }
        }
        
        if isValid && selectedTab == "Single" && Int(singleTime.timeIntervalSince1970) <= Int(Date().timeIntervalSince1970) {
            isValid = false
            showAlert("Please select a time in the future")
        }
        
        if isValid != true {
            moc.reset()
        }
        
        return isValid
    }
    
    var formButtons: some View {
        HStack {
            Spacer()
            
            Button("Add", action: submitForm)
                .buttonStyle(FormButton())
            
            Button("Cancel", role: .cancel, action: dismiss.callAsFunction)
                .buttonStyle(FormButton(backgroundColor: .gray))
            
            Spacer()
        }
    }
    
    func showAlert(_ message: String) {
        alertMessage = message
        alertIsPresented = true
    }
}

struct AddCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        AddCountdownView()
    }
}

extension Date {
    var omittingSecondsToZero: Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents)
    }
}
