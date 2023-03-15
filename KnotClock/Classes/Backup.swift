//
//  Backup.swift
//  KnotClock
//
//  Created by NA on 3/14/23.
//

import SwiftUI
import UniformTypeIdentifiers

class Backup {
    #if os(macOS)
    func save() {
        let backupFileName = "\(K.appName) Backup \(DateHelper().getCurrent()).sqlite"
        
        let backupDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupURL = backupDirectory.appendingPathComponent(backupFileName)
        let coordinator = DataController().container.persistentStoreCoordinator
        
        // Delete older backup with same backupFileName
        try? FileManager.default.removeItem(at: backupURL)
        
        if let store = coordinator.persistentStores.first {
            // Save new backup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                do {
                    let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
                    try coordinator.migratePersistentStore(store, to: backupURL, options: options, withType: NSSQLiteStoreType)
                    
                    // Open path in Finder
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: backupDirectory.path())
                } catch {
                    Alerts.show("Failed to create/store backup file: \(error)")
                }
            }
        }
    }
    func restore() {
        guard let backupFileType = UTType.init(filenameExtension: "sqlite") else { return }
        
        let coordinator = DataController.shared.container.persistentStoreCoordinator
        let stores = coordinator.persistentStores
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [backupFileType]
        if panel.runModal() == .OK, let selectedBackupURL = panel.url, let storeURL = stores.first?.url {
            do {
                try coordinator.replacePersistentStore(at: storeURL, destinationOptions: nil, withPersistentStoreFrom: selectedBackupURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
                Countdowns.shared.reset(level: .reloadContainerRefetchResetNotifs)
            } catch {
                Alerts.show("Failed to restore backup file: \(error)")
            }
        }
    }
    #endif
}
