//
//  HomeViewModel.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
import Combine

/// Drives the Home screen: progress, the next action and the next appointment.
@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var requirements: [HealthRequirement] = []
    @Published private(set) var appointments: [Appointment] = []

    /// A message for the applicant when something goes wrong, or nil when everything is working.
    @Published var errorMessage: String?

    private let requirementRepository: HealthRequirementRepository
    private let appointmentRepository: AppointmentRepository

    init(
        requirementRepository: HealthRequirementRepository,
        appointmentRepository: AppointmentRepository
    ) {
        self.requirementRepository = requirementRepository
        self.appointmentRepository = appointmentRepository
    }

    /// Loads what Home shows. Call this when the screen appears.
    func load() {
        do {
            requirements = try requirementRepository.fetchAll()
            appointments = try appointmentRepository.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = "We couldn't load your home screen. Close the app and open it again. If it keeps happening, check that your phone has free storage."
        }
    }

    /// How many requirements the applicant has.
    var totalCount: Int {
        return requirements.count
    }

    /// How many requirements are completed.
    var completedCount: Int {
        var count = 0
        for requirement in requirements {
            if requirement.status == .completed {
                count += 1
            }
        }
        return count
    }

    /// Progress from 0 to 1, for the progress bar.
    var progressFraction: Double {
        if totalCount == 0 {
            return 0
        }
        return Double(completedCount) / Double(totalCount)
    }

    /// The requirement to do next: the earliest due date that isn't completed.
    /// Overdue requirements come first, because the repository returns requirements by due date.
    var nextAction: HealthRequirement? {
        for requirement in requirements {
            if requirement.status != .completed {
                return requirement
            }
        }
        return nil
    }

    /// The next appointment that hasn't been attended and hasn't passed.
    /// The repository returns appointments earliest first.
    var upcomingAppointment: Appointment? {
        let now = Date()
        for appointment in appointments {
            if !appointment.isCompleted && appointment.date >= now {
                return appointment
            }
        }
        return nil
    }
    
    /// The requirements the applicant completed most recently, newest first (up to three).
    var recentActivity: [HealthRequirement] {
        var completed: [HealthRequirement] = []
        for requirement in requirements {
            if requirement.status == .completed && requirement.completedDate != nil {
                completed.append(requirement)
            }
        }

        let newestFirst = completed.sorted {
            ($0.completedDate ?? Date.distantPast) > ($1.completedDate ?? Date.distantPast)
        }

        return Array(newestFirst.prefix(3))
    }
}
