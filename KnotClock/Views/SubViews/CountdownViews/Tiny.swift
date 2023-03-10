//
//  Tiny.swift
//  KnotClock
//
//  Created by NA on 2/28/23.
//

import SwiftUI

struct Tiny: View {
    @State private var showingPopover = false
    @State private var showCompletely = false
    @State private var timer: Timer? = nil
    @State private var countdown: Countdown
    private let remainingTime: RemainingTimeDetails
    
    init(_ countdown: Countdown) {
        _countdown = State(initialValue: countdown)
        remainingTime = countdown.remainingTime
    }
    
    var body: some View {
        let text = showCompletely ? "\(countdown.title) : \(remainingTime.formattedFullTime)" : countdown.getTruncatedTitle()
        HStack {
            if remainingTime.inSeconds < 0 {
                Image(systemName: "checkmark.square").onTapGesture {
                    countdown.deleteExpiredSingleHideDaily()
                }
            }
            Text(text).font(.footnote)
                .onHover { hovering in
                    if hovering {
                        showingPopover = true
                    } else {
                        showingPopover = false
                    }
                }
        }
        .padding(.all, 5)
        .lineLimit(1)
        .background(.quaternary)
        .cornerRadius(5)
        #if os(macOS)
        .popover(isPresented: $showingPopover) {
            VStack {
                Text(countdown.title).bold()
                Text(remainingTime.formattedFullTime)
                    .font(.headline)
            }
            .padding()
            .frame(minWidth: 130)
        }
        #else
        .onTapGesture {
            withAnimation {
                showCompletely = true
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                withAnimation {
                    showCompletely = false
                }
            }
        }
        #endif
    }
}
