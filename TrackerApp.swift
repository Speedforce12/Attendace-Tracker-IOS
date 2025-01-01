//
//  TrackerApp.swift
//  Tracker
//
//  Created by speedy on 12/26/24.
//

import SwiftUI
import SwiftData

@main
struct TrackerApp: App {
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Employee.self, Attendance.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: [Employee.self, Attendance.self], inMemory: true)
    }
}
