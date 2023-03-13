//
//  OverviewSingleCountdownWithAction.swift
//  KnotClock
//
//  Created by NA on 3/6/23.
//

import SwiftUI

struct OverviewSingleCountdownWithAction: View {
    @Environment(\.managedObjectContext) var moc
    @State private var showingDeleteConfirmation = false
    
    let singleCountdown: Single
    
    var body: some View {
        HStack {
            Text(singleCountdown.title ?? "").bold()
            
            if let deadlineDate = singleCountdown.deadlineDate {
                Text(deadlineDate.formatted()).padding(.horizontal)
            }
            
            Spacer()
            
            actionButton("x.circle.fill") {
                showingDeleteConfirmation = true
            }
        }
        .frame(maxWidth: K.MacWindowSizes.Overview.maxWidth)
        .padding()
        .background(.quaternary)
        .cornerRadius(5)
        .confirmationDialog("Deleting: \(singleCountdown.title ?? "")", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive, action: deleteCompletely)
            Button("Cancel", role: .cancel) {
                showingDeleteConfirmation = false
            }
        }
    }
    
    func getFormattedFullTime() -> String {
        if let id = singleCountdown.id, let title = singleCountdown.title {
            let countdown = Countdown(id: id, title: title, category: .single, time: Int(singleCountdown.deadlineEpoch))
            return countdown.remainingTime.formattedFullTime
        }
        
        return ""
    }
    
    func deleteCompletely() {
        moc.delete(singleCountdown)
        saveMOC()
    }
    
    func saveMOC() {
        do {
            try moc.save()
        } catch {
            Countdowns.shared.alertMessage = error.localizedDescription
            Countdowns.shared.showAlert = true
        }
    }
}
