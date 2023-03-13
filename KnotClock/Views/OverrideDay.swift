//
//  OverrideDay.swift
//  KnotClock
//
//  Created by NA on 3/7/23.
//

import SwiftUI

struct OverrideDay: View {
    @AppStorage(K.StorageKeys.userPreferences) var preferences = Preferences(x: DefaultUserPreferences())
    @ObservedObject private var countdowns = Countdowns.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showConfirm = false
    @State private var confirmForDay = ""
    
    var body: some View {
        VStack {
            Text("Override Today As:")
            
            ForEach(K.weekdays, id: \.self) { day in
                overrideButton(for: day)
                    .disabled(todayName().lowercased() == day.lowercased())
            }
            
            Text("This will only affect Daily Countdowns for Today").font(.footnote).padding(.top)
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        .padding()
        .confirmationDialog("Are you sure you want to override today as \(confirmForDay.capitalized)?", isPresented: $showConfirm) {
            Button("Yes, override") {
                override(to: confirmForDay)
            }
            
            Button("Cancel", role: .cancel){
                confirmForDay = ""
                showConfirm = false
            }
        }
    }
    
    func override(to day: String) {
        countdowns.overrideToday(as: day)
        dismiss()
    }
    
    func todayName() -> String {
        if let overridenAs = countdowns.todayIsOverriddenAs() {
            return overridenAs
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    func overrideButton(for day: String) -> some View {
        Button {
            confirmForDay = day
            showConfirm = true
        } label: {
            Text(day.capitalized).frame(width: 150)
        }
        .padding(.all, 2)
    }
}

struct OverrideDay_Previews: PreviewProvider {
    static var previews: some View {
        OverrideDay()
    }
}
