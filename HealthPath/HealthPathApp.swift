//
//  HealthPathApp.swift
//  HealthPath
//
//  Created by emily zhang on 26/9/2026.
//

import SwiftUI
import SwiftData

@main
struct HealthPathApp: App {
    private let container: ModelContainer
    private let caseRepository: any HealthCaseRepository
    private let requirementRepository: any HealthRequirementRepository
    private let appointmentRepository: any AppointmentRepository

    init() {
        let container = try! ModelContainer(
            for: HealthCaseModel.self,
            HealthRequirementModel.self,
            AppointmentModel.self,
            DocumentModel.self
        )
        let context = container.mainContext
        self.container = container
        caseRepository = SwiftDataHealthCaseRepository(modelContext: context)
        requirementRepository = SwiftDataHealthRequirementRepository(modelContext: context)
        appointmentRepository = SwiftDataAppointmentRepository(modelContext: context)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                caseRepository: caseRepository,
                requirementRepository: requirementRepository,
                appointmentRepository: appointmentRepository
            )
        }
        .modelContainer(container)
    }
}
