//
//  MainView.swift
//  KnotClock
//
//  Created by NA on 2/19/23.
//

import SwiftUI
import Combine

struct MainView: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject private var countdowns = Countdowns.shared
    @State private var showAddCountdownSheet = false
    @State private var showWeeklyOverviewSheet = false
    @State private var showOverrideDaySheet = false
    private var isInMenubar: Bool
    
    @AppStorage(K.userPreferencesKey) var preferences = Preferences(x: DefaultUserPreferences())
    
    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif
    
    init(isInMenubar: Bool = false) {
        self.isInMenubar = isInMenubar
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: countdowns.thereAreNoCountdowns() ? .center : .leading) {
                if countdowns.thereAreNoCountdowns() {
                    Text("No countdowns for today.")
                } else {
                    displayCountdowns()
                }
            }
            .onAppear {
                countdowns.refetchAllAndHandleNotifications()
            }
            .alert(countdowns.alertMessage, isPresented: $countdowns.showAlert) {
                Button("OK"){}
            }
            .sheet(isPresented: $showAddCountdownSheet, onDismiss: countdowns.refetchAllAndHandleNotifications) {
                AddCountdownView(isInMenubar: isInMenubar)
            }
            .sheet(isPresented: $showWeeklyOverviewSheet, onDismiss: countdowns.refetchAllAndHandleNotifications) {
                OverviewCountdowns()
            }
            .sheet(isPresented: $showOverrideDaySheet, onDismiss: countdowns.refetchAllAndHandleNotifications) {
                OverrideDay()
            }
            .onChange(of: preferences.x.refreshTimerInterval) { newValue in
                countdowns.rescheduleTimer(interval: newValue)
            }
            .padding()
            .toolbar {
                if let overridenAs = countdowns.todayIsOverriddenAs() {
                    ToolbarItem(placement: .status) {
                        Text("Overridden as \(overridenAs.capitalized)").font(.footnote).foregroundColor(.secondary)
                    }
                }
                toolbar()
            }
            
            #if os(macOS)
            if isInMenubar {
                HStack {
                    Spacer()
                    Button("Add") {
                        showAddCountdownSheet = true
                    }
                    Button("Main Window") {
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: K.appName)
                        NSApp.mainWindow?.orderFrontRegardless()
                    }
                    Button("Settings") {
                        NSApp.activate(ignoringOtherApps: true)
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                    Button("Quit") {
                        NSApp.terminate(nil)
                    }
                    Spacer()
                }
                .padding(.bottom)
            }
            #endif
        }
    }
    
    @ViewBuilder
    func displayCountdowns() -> some View {
        let CurStyle = preferences.x.currentCountdownStyle
        let upStyle = preferences.x.upcommingCountdownStyle
        let exStyle = preferences.x.expiredCountdownStyle
                
        if [.hide, .tiny].contains(upStyle) && [.hide, .tiny].contains(exStyle) {
            countdownsView(for: .current)
            if !isInMenubar && CurStyle != .tiny {
                Spacer()
            }
            countdownsView(for: .upcomming)
            countdownsView(for: .expired)
            
            if CurStyle == .tiny {
                Spacer()
            }
        }
        
        else if upStyle == .tiny && [.small, .fullSize].contains(exStyle) {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    countdownsView(for: .current)
                    countdownsView(for: .expired)
                    countdownsView(for: .upcomming)
                }
                .padding(3)
                .frame(minWidth: K.MacWindowSizes.Menubar.minWidth - K.MacWindowSizes.countdownVStackWidthSubtract)
            }
        }
        
        else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    countdownsView(for: .current)
                    countdownsView(for: .upcomming)
                    countdownsView(for: .expired)
                }
                .padding(3)
                .frame(minWidth: K.MacWindowSizes.Menubar.minWidth - K.MacWindowSizes.countdownVStackWidthSubtract)
            }
        }
    }
    
    @ViewBuilder
    func countdownsView(for group: CountdownGroup) -> some View {
        switch group {
        case .current:
            showCurrent()
        case .upcomming:
            showUpcommingExpired(countdowns.upcomming, .upcomming)
        case .expired:
            showUpcommingExpired(countdowns.expired, .expired)
        }
    }
    
    @ViewBuilder
    func showCurrent() -> some View {
        let setting = preferences.x.currentCountdownStyle
        
        switch setting {
        case .tiny:
            Text("Current:").bold()
            tiny(countdowns.current)
        case .small:
            small(countdowns.current)
        default:
            fullSize(countdowns.current)
        }
    }
    
    @ViewBuilder
    func showUpcommingExpired(_ cds: [Countdown], _ group: CountdownGroup) -> some View {
        if cds.count > 0 {
            let setting = (group == .upcomming) ? preferences.x.upcommingCountdownStyle : preferences.x.expiredCountdownStyle
            
            if group == .expired && setting != .hide {
                Text("Expired:").bold().padding(.top)
            }
            
            switch setting {
            case .hide:
                EmptyView()
            case .tiny:
                if group == .upcomming {
                    Text("Upcomming:").bold().padding(.top)
                }
                tiny(cds)
            case .small:
                small(cds)
            case .fullSize:
                fullSize(cds, forcingExpired: (group == .expired) ? true : false)
            }
        }
    }
    
    func toolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Spacer()
            
            #if os(macOS)
            Button {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } label: {
                Image(systemName: "gear")
            }
            #else
            // iOS Focus Mode
            NavigationLink(destination: FocusModeView()) {
                Image(systemName: "binoculars")
            }
            
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gear")
            }
            #endif
            
            Button {
                showOverrideDaySheet = true
            } label: {
                Image(systemName: "cursorarrow.click.badge.clock")
            }
            
            Button {
                showWeeklyOverviewSheet = true
            } label: {
                Image(systemName: "calendar.badge.clock")
            }
            
            Button {
                showAddCountdownSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
