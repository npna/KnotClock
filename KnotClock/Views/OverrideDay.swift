//
//  OverrideDay.swift
//  KnotClock
//
//  Created by NA on 3/7/23.
//

import SwiftUI

struct OverrideDay: View {
    @EnvironmentObject private var countdowns: Countdowns
    @Environment(\.dismiss) private var dismiss
    
    @State private var showConfirm = false
    @State private var confirmForDay = ""
    
    private let dateHelper = DateHelper()
    
    var body: some View {
        VStack {
            Text("Override Today As:")
            
            ForEach(K.weekdays, id: \.self) { day in
                overrideButton(for: day)
                    .disabled(dateHelper.weekdayName(allowOverride: true).lowercased() == day.lowercased())
            }
            
            Text("This will only affect Daily Countdowns for Today").font(.footnote).padding(.top)
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        .padding()
        .confirmationDialog("Are you sure you want to override today as \(confirmForDay.capitalized)?", isPresented: $showConfirm) {
            Button("Yes, override") {
                dateHelper.overrideToday(as: confirmForDay)
                showConfirm = false
                dismiss()
            }
            
            Button("Cancel", role: .cancel){
                confirmForDay = ""
                showConfirm = false
            }
        }
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
