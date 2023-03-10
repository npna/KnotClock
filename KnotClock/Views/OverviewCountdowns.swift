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
        
    var body: some View {
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
            
            Text("Single countdowns:").bold().padding(.top)
            
            ScrollView(.horizontal) {
                let singles = countdowns.getSingles(fetchLimit: 10, excludeExpired: true, limitByMaxEpoch: false)

                HStack {
                    if singles.count > 0 {
                        ForEach(singles) { single in
                            OverviewSingleCountdownWithAction(singleCountdown: single)
                        }
                    } else {
                        Text("None!")
                    }
                }
                .padding(.bottom)
            }
        }
        .frame(maxWidth: 600)
        .padding()
        
        Button("Close", action: dismiss.callAsFunction).padding(.bottom)
    }
}

struct OverviewCountdowns_Previews: PreviewProvider {
    static var previews: some View {
        OverviewCountdowns()
    }
}
