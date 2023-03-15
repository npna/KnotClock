//
//  OverviewSingleCountdownWithAction.swift
//  KnotClock
//
//  Created by NA on 3/6/23.
//

import SwiftUI

struct OverviewSingleCountdownWithAction: View {
    @Environment(\.managedObjectContext) var moc
    @State private var showingDeleteConfirmation = false
    @State private var showingEditPopover = false
    
    private let singleCountdown: Single
    private var validTime: Bool = true
    
    @State private var title: String
    @State private var deadlineDate: Date
    
    init(singleCountdown: Single) {
        self.singleCountdown = singleCountdown
        _title = State(initialValue: singleCountdown.title ?? "")
        if let convertDeadlineToDate = singleCountdown.deadlineDate {
            _deadlineDate = State(initialValue: convertDeadlineToDate)
        } else {
            _deadlineDate = State(initialValue: Date())
            validTime = false
        }
    }
    
    var body: some View {
        if validTime {
            bodyContent
        } else {
            Text("Something went wrong...").font(.footnote).foregroundColor(.red)
        }
    }
    
    @ViewBuilder
    var bodyContent: some View {
        HStack {
            Text(singleCountdown.title ?? "").bold()
            
            if let deadlineDate = singleCountdown.deadlineDate {
                Text(deadlineDate.formatted()).padding(.horizontal)
            }
            
            Spacer()
            
            actionIconButton("pencil.circle.fill", .blue) {
                showingEditPopover = true
            }
            
            actionIconButton("x.circle.fill") {
                showingDeleteConfirmation = true
            }
        }
        .frame(maxWidth: K.FrameSizes.Mac.Overview.maxWidth)
        .padding()
        .background(.quaternary)
        .cornerRadius(5)
        .confirmationDialog("Deleting: \(singleCountdown.title ?? "")", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive, action: deleteCompletely)
            Button("Cancel", role: .cancel) {
                showingDeleteConfirmation = false
            }
        }
        .popover(isPresented: $showingEditPopover) {
            Text("Edit this countdown:").bold().padding(.horizontal).padding(.top)
            Form {
                TextField("Title", text: $title)
                DatePicker("Time", selection: $deadlineDate)
                
                HStack(alignment: .center) {
                    Button("Save", action: saveEdits)
                        .buttonStyle(FormButton())
                    Button("Cancel", role: .cancel) { showingEditPopover = false }
                        .buttonStyle(FormButton(backgroundColor: .gray))
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    func saveEdits() {
        singleCountdown.setValue(title, forKey: "title")
        let deadlineEpoch = Int64((deadlineDate.omittingSecondsToZero ?? deadlineDate).timeIntervalSince1970)
        singleCountdown.setValue(deadlineEpoch, forKey: "deadlineEpoch")
        showingEditPopover = false
        
        saveMOC()
    }
    
    func deleteCompletely() {
        moc.delete(singleCountdown)
        saveMOC()
    }
    
    func saveMOC(didEdit: Bool = true) {
        do {
            try moc.save()
            Countdowns.shared.reset(level: .refetchResetNotifs)
        } catch {
            Alerts.show(error.localizedDescription)
        }
    }
}
