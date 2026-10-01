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
    let dependencies: AppDependencies

    init() {
        dependencies = AppDependencies(
            context: PersistenceController.shared.container.viewContext
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
