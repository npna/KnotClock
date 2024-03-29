//
//  DebugView.swift
//  KnotClock
//
//  Created by NA on 3/15/23.
//

import SwiftUI

struct DebugView: View {
    @AppStorage(K.StorageKeys.userPreferences) private var preferences = Preferences(x: DefaultUserPreferences())
    @State private var level: CountdownResetLevel = .reloadContainerRefetchResetNotifs
    
    var body: some View {
        scrollViewOnMac("Debug Mode (for quick testing)") {
            Form {
                RunAfterConfirmation("Clear Database") { confirmed in
                    DataController.shared.clearEntireCoreData(confirm: confirmed)
                }
                
                RunAfterConfirmation("Reset Everything") { confirmed in
                    preferences.resetAllTo(DefaultUserPreferences())
                    DataController.shared.clearEntireCoreData(confirm: confirmed)
                }
                
                RunAfterConfirmation("Clear DB & Add Random Data") { confirmed in
                    DataController.shared.clearAndFillWithRandomData(confirm: confirmed)
                }
                
                Text("Warning - These options are only intended for testing purposes. Pressing the buttons above will remove your countdowns permanently!").foregroundColor(.red).bold().padding(.top)
                
                Section("Refresh with Level") {
                    Picker("Level", selection: $level) {
                        ForEach(CountdownResetLevel.allCases, id:\.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                    
                    Button("Reset") {
                        Countdowns.shared.reset(level: level)
                    }
                }
                .padding(.top)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}
