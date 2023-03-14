//
//  ContextualMenu.swift
//  KnotClock
//
//  Created by NA on 3/14/23.
//

import SwiftUI

struct ContextualMenu: ViewModifier {
    @Binding fileprivate var countdown: Countdown
    @State private var showConfirmation = false
    
    func body(content: Content) -> some View {
        content.contextMenu {
            if countdown.isHidden {
                Button {
                    Countdowns.shared.unhideDaily(countdown.id)
                } label: {
                    Label("Unhide", systemImage: "eye").labelStyle(.titleAndIcon)
                }
            } else {
                Button {
                    showConfirmation = true
                } label: {
                    Label(countdown.category == .daily ? "Hide" : "Delete", systemImage: countdown.category == .daily ? "eye.slash" : "trash").labelStyle(.titleAndIcon)
                }
            }
        }
        .confirmationDialog("Are you sure you want to \(countdown.category == .daily ? "hide" : "delete") this item?", isPresented: $showConfirmation) {
            Button("Yes", role: .destructive) {
                countdown.deleteExpiredSingleHideDaily(dontCheckRemainingSeconds: true)
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
}

extension View {
    func contextualMenu(for countdown: Binding<Countdown>) -> some View {
        self.modifier(ContextualMenu(countdown: countdown))
    }
}
