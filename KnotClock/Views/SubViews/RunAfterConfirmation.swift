//
//  RunAfterConfirmation.swift
//  KnotClock
//
//  Created by NA on 3/15/23.
//

import SwiftUI

struct RunAfterConfirmation: View {
    @State private var showConfirmation = false
    let buttonName: String
    let confirmationMessage: String
    let content: (Bool) -> ()
    
    
    init(_ buttonName: String, confirmationMessage: String = "Are you sure?", content: @escaping (Bool) -> ()) {
        self.content = content
        self.buttonName = buttonName
        self.confirmationMessage = confirmationMessage
    }
    
    var body: some View {
        Button(buttonName) {
            showConfirmation = true
        }
        .alert(confirmationMessage, isPresented: $showConfirmation) {
            Button("Yes", role: .destructive) {
                content(true)
            }
            
            Button("No", role: .cancel) { }
        }
    }
}
