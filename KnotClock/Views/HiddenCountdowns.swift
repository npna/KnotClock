//
//  HiddenCountdowns.swift
//  KnotClock
//
//  Created by NA on 3/14/23.
//

import SwiftUI

struct HiddenCountdowns: View {
    @ObservedObject private var countdowns = Countdowns.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("Hidden non-expired daily countdowns:").bold().padding(.top)
        VStack {
            if countdowns.hidden.count == 0 {
                Text("None!")
            }
            
            small(countdowns.hidden)
            
            Button("Close") {
                dismiss()
            }
            .padding(.top)
        }
        .padding()
        .frame(minWidth: 300)
    }
}

struct HiddenCountdowns_Previews: PreviewProvider {
    static var previews: some View {
        HiddenCountdowns()
    }
}
