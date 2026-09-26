//
//  HealthPathApp.swift
//  HealthPath
//
//  Created by emily zhang on 26/9/2026.
//

import SwiftUI
import CoreData

@main
struct HealthPathApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
