//
//  OverviewSingleCountdownWithAction.swift
//  KnotClock
//
//  Created by NA on 3/6/23.
//

import SwiftUI

struct OverviewSingleCountdownWithAction: View {
    @State private var showingPopover = false
    @Environment(\.managedObjectContext) var moc
    @State private var showingDeleteConfirmation = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let singleCountdown: Single
    
    var body: some View {
        HStack {
            Text(singleCountdown.title ?? "").font(.footnote)
                .padding(.all, 5)
                .lineLimit(1)
                .onHover { hovering in
                    if hovering {
                        showingPopover = true
                    } else {
                        showingPopover = false
                    }
                }
            
            actionButton("x.circle.fill") {
                showingDeleteConfirmation = true
            }
        }
        .background(.quaternary)
        .cornerRadius(5)
        .popover(isPresented: $showingPopover) {
            Text(getFormattedFullTime())
                .font(.headline)
                .padding()
                .frame(minWidth: 120)
        }
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
