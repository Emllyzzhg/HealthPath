//
//  CompleteHealthRequirementUseCase.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation

/// Marks one of the applicant's health requirements as completed.
/// For example, once an applicant has had their chest X-ray, they open "Chest X-ray" and mark it as completed. It then moves out of their outstanding actions and counts towards their progress on Home.
/// HealthPath keeps the applicant's own record. Marking a requirement as completed does not tell Home Affairs or eMedical, and it does not decide whether the requirement has been met.
///
/// Business rules
/// 1. The requirement must exist.
/// 2. A completed requirement cannot be completed again.
/// 3. The status must be updated and saved.
///
/// This use case never talks to the database directly.
/// The requirement shows "Completed" in green on the Requirements list and its details screen. Completing a requirement doesn't touch its appointments or documents, and it doesn't record a completion date.
/// Home counts it in "completed" progress (for example "3 of 5") and no longer shows it as the next action. The widget stops showing it.
/// When a rule is broken, the screen shows the error's message and nothing is saved.

struct CompleteHealthRequirementUseCase {

    private let repository: HealthRequirementRepository

    init(repository: HealthRequirementRepository) {
        self.repository = repository
    }

    /// Marks the requirement as completed.
    /// The requirement to complete, for example "Chest X-ray".
    /// - Throws: CompleteHealthRequirementError/requirementNotFound if the requirement does not exist, or CompleteHealthRequirementError/alreadyCompleted if it is already completed.
    func execute(id: UUID) throws {
        // Rule 1: the requirement must exist.
        guard var requirement = try repository.fetchRequirement(withID: id) else {
            throw CompleteHealthRequirementError.requirementNotFound
        }

        // Rule 2: a completed requirement cannot be completed again.
        if requirement.status == .completed {
            throw CompleteHealthRequirementError.alreadyCompleted
        }

        // Rule 3: update the status and save it.
        requirement.status = .completed
        try repository.update(requirement)
    }
}
