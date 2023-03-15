//
//  BackupRestore.swift
//  KnotClock
//
//  Created by NA on 3/14/23.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

#if os(macOS)
extension Countdowns {
    func backup() {
        let backupFileName = "\(K.appName) Backup \(getCurrentDate()).sqlite"
        
        let backupDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupURL = backupDirectory.appendingPathComponent(backupFileName)
        let coordinator = DataController().container.persistentStoreCoordinator
        
        // Delete older backup with same backupFileName
        try? FileManager.default.removeItem(at: backupURL)
        
        if let store = coordinator.persistentStores.last {
            // Save new backup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                do {
                    let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
                    try coordinator.migratePersistentStore(store, to: backupURL, options: options, withType: NSSQLiteStoreType)
                    
                    // Open path in Finder
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: backupDirectory.path())
                } catch {
                    self.alertMessage = "Failed to create/store backup file: \(error)"
                    self.showAlert = true
                }
            }
        }
    }
    
    func restoreBackup() {
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
                reset(level: .reloadContainerRefetchResetNotifs)
            } catch {
                self.alertMessage = "Failed to restore backup file: \(error)"
                self.showAlert = true
            }
        }
    }
}
#endif
