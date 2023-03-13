//
//  FocusModeView.swift
//  KnotClock
//
//  Created by NA on 3/6/23.
//

import SwiftUI

struct FocusModeView: View {
    @ObservedObject private var countdowns = Countdowns.shared
    @Environment(\.dismiss) private var dismiss
    @AppStorage(K.StorageKeys.userPreferences) var preferences = Preferences(x: DefaultUserPreferences())
    private var countdown: Countdown? = nil
    
    @State private var timer = Timer.publish(every: 9.5, on: .main, in: .common).autoconnect()
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    init() {
        if let nextCountdown = countdowns.current.first {
            countdown = nextCountdown
        }
    }
    
    var body: some View {
        ZStack {
            if let countdown {
                let remainingTime = countdown.remainingTime
                Color.black
                HStack {
                    Spacer()
                    
                    HStack {
                        let firstLetter = countdown.title.prefix(1).lowercased()
                        Image(systemName: "\(firstLetter).square.fill").font(.largeTitle)
                        
                        timeView(remainingTime, .focus, preferences)
                    }
                    .foregroundColor(getCountdownIndicationColor(remainingTime: remainingTime, defaultColor: .gray, opacity: 1, preferences: preferences))
                    .transition(.slide)
                    .padding()
                    .background(getCountdownIndicationColor(remainingTime: remainingTime, defaultColor: .black, opacity: 0.1, preferences: preferences))
                    .cornerRadius(K.FullSizeCountdown.cornerRadius)
                    .offset(x: offsetX, y: offsetY)
                    
                    Spacer()
                }
            } else {
                Text("No Countdowns")
            }
        }
        .onTapGesture {
            dismiss()
        }
        .onAppear {
            if countdown == nil {
                dismiss()
            }
            moveCountdownRandomlyWithAnimation()
        }
        .onReceive(timer) { _ in
            moveCountdownRandomlyWithAnimation()
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
    
    func moveCountdownRandomlyWithAnimation() {
        withAnimation(Animation.easeInOut(duration: 10)) {
            // This is to avoid burn-in
            offsetX = .random(in: -60...60)
            offsetY = .random(in: -60...60)
        }
    }
    
    var separator: some View {
        Text(":").bold().foregroundColor(.gray)
    }
}

struct FocusModeView_Previews: PreviewProvider {
    static var previews: some View {
        FocusModeView()
    }
}
