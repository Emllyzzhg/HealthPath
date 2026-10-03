//
//  RequirementDetailViewModel.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
import Combine

/// Drives the Requirement Details screen: one requirement, the appointments kept with it, and marking it as completed.
@MainActor
final class RequirementDetailViewModel: ObservableObject {

    @Published private(set) var requirement: HealthRequirement
    @Published private(set) var appointments: [Appointment] = []

    /// A message for the applicant when something goes wrong, or nil when all is well.
    @Published var errorMessage: String?

    private let requirementRepository: HealthRequirementRepository
    private let appointmentRepository: AppointmentRepository
    private let completeUseCase: CompleteHealthRequirementUseCase

    init(
        requirement: HealthRequirement,
        requirementRepository: HealthRequirementRepository,
        appointmentRepository: AppointmentRepository,
        completeUseCase: CompleteHealthRequirementUseCase
    ) {
        self.requirement = requirement
        self.requirementRepository = requirementRepository
        self.appointmentRepository = appointmentRepository
        self.completeUseCase = completeUseCase
    }

    /// Reloads the requirement and its appointments. Call this when the screen appears.
    func load() {
        errorMessage = nil

        do {
            guard let latest = try requirementRepository.fetchRequirement(withID: requirement.id
            ) else {
                errorMessage = "We couldn't find this requirement. Go back to your requirements and try again."
                return
            }
            requirement = latest
            appointments = try appointmentRepository.fetchAppointments(for: requirement.id)
        } catch {
            errorMessage = "We couldn't load this requirement. Close the app and open it again. If it keeps happening, check that your phone has free storage."
        }
    }

    /// Marks this requirement as completed.
    func complete() {
        errorMessage = nil

        do {
            try completeUseCase.execute(id: requirement.id)
            load()
        } catch {
            if let completeError = error as? CompleteHealthRequirementError {
                errorMessage = completeError.errorDescription
            } else if let repositoryError = error as? HealthRequirementRepositoryError {
                errorMessage = repositoryError.errorDescription
            } else {
                errorMessage = "We couldn't mark this requirement as completed. Close the app and open it again, then try once more."
            }
        }
    }
}
