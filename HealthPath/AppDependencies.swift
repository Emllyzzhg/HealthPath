//
//  AppDependencies.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
import CoreData

/// Builds the repositories and use cases the screens need, so the connections live in one place.
struct AppDependencies {

    let caseRepository: HealthCaseRepository
    let requirementRepository: HealthRequirementRepository
    let appointmentRepository: AppointmentRepository

    let addRequirementUseCase: AddHealthRequirementUseCase
    let completeRequirementUseCase: CompleteHealthRequirementUseCase
    let scheduleAppointmentUseCase: ScheduleHealthAppointmentUseCase

    init(context: NSManagedObjectContext) {
        caseRepository = CoreDataHealthCaseRepository(context: context)
        requirementRepository = CoreDataHealthRequirementRepository(context: context)
        appointmentRepository = CoreDataAppointmentRepository(context: context)

        addRequirementUseCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        completeRequirementUseCase = CompleteHealthRequirementUseCase(
            repository: requirementRepository
        )
        scheduleAppointmentUseCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
    }

    /// Creates the view model for the Requirements screens.
    @MainActor
    func makeRequirementViewModel(healthCaseID: UUID) -> HealthRequirementViewModel {
        return HealthRequirementViewModel(
            repository: requirementRepository,
            addUseCase: addRequirementUseCase,
            completeUseCase: completeRequirementUseCase,
            healthCaseID: healthCaseID
        )
    }

    /// Creates the view model for the Appointments screens.
    @MainActor
    func makeAppointmentViewModel() -> AppointmentViewModel {
        return AppointmentViewModel(
            repository: appointmentRepository,
            scheduleUseCase: scheduleAppointmentUseCase
        )
    }

    /// Creates the view model for the Requirement Details screen.
    @MainActor
    func makeRequirementDetailViewModel(requirement: HealthRequirement) -> RequirementDetailViewModel {
        return RequirementDetailViewModel(
            requirement: requirement,
            requirementRepository: requirementRepository,
            appointmentRepository: appointmentRepository,
            completeUseCase: completeRequirementUseCase
        )
    }
}
