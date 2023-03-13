//
//  OverviewCountdowns.swift
//  KnotClock
//
//  Created by NA on 3/1/23.
//

import SwiftUI

struct OverviewCountdowns: View {
    @EnvironmentObject var countdowns: Countdowns
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: String = "Daily"
        
    var body: some View {
        TabView(selection: $selectedTab) {
            overviewDailiesTab
                .tabItem {
                    Label("Daily Countdowns", systemImage: "list.dash")
                }
                .tag("Daily")
            
            overviewSinglesTab
                .tabItem {
                    Label("Single Countdowns", systemImage: "square.and.pencil")
                }
                .tag("Single")
        }
        .macOSPadding(.top)
        
        Button("Close", action: dismiss.callAsFunction).padding(.bottom)
    }
    
    var overviewDailiesTab: some View {
        VStack(alignment: .leading) {
            Text("Weekly overview of daily countdowns:").bold().padding(.bottom)
            
            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(K.weekdays, id: \.self) { day in
                        HStack(spacing: 0) {
                            VStack {
                                Text(day.capitalized).lineLimit(1).bold()
                            }
                            .padding()
                            .frame(minWidth: 130, maxHeight: .infinity, alignment: .leading)
                            .background(K.WeeklyOverview.weekdayNameColumnBG)
                            
                            let countdownsForThisWeekday = countdowns.getDailies(for: day)
                            
                            if countdownsForThisWeekday.count == 0 {
                                Divider().background(K.WeeklyOverview.borderColor)
                                Text("-").padding(.horizontal)
                            }
                            
                            ForEach(countdownsForThisWeekday, id:\.forEachID) { dailyCountdown in
                                OverviewDailyCountdownTableCellWithAction(dailyCountdown: dailyCountdown, weekday: day)
                            }
                            
                            Spacer()
                        }
                        .border(K.WeeklyOverview.borderColor, width: 1)
                    }
                }
            }
        }
        .frame(maxWidth: K.FrameSizes.Mac.Overview.maxWidth)
        .padding()
    }
    
    var overviewSinglesTab: some View {
        VStack(alignment: .leading) {
            Text("Overview your single countdowns:").bold().padding(.bottom)
            
            let singles = countdowns.getSingles(fetchLimit: 500, excludeExpired: true, limitByMaxEpoch: false)
            
            if singles.count == 0 {
                Text("None!")
            } else {
                ScrollView(.vertical) {
                    ForEach(singles) { single in
                        OverviewSingleCountdownWithAction(singleCountdown: single)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: K.FrameSizes.Mac.Overview.maxWidth, alignment: .topLeading)
        .padding()
    }
}

struct OverviewCountdowns_Previews: PreviewProvider {
    static var previews: some View {
        OverviewCountdowns()
    }
}
