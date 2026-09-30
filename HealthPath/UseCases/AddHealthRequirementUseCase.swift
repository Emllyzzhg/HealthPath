//
//  AddHealthRequirementUseCase.swift
//  HealthPath
//
//  Created by emily zhang on 30/9/2026.
//

import Foundation

/// Adds a health requirement to the applicant's health case.
/// For example, an applicant who has been asked to complete a chest X-ray by 25 October can record it here. It then appears in their requirements list, on Home and in the widget.
/// HealthPath keeps the applicant's own record of what they have been asked to do. It does not check a requirement with Home Affairs or eMedical.
///
/// Business rules
/// 1. A requirement must have a title, such as "Chest X-ray".
/// 2. A requirement must have a valid due date, within five years of today. A date in the past is allowed, because the applicant may be recording a requirement that is already late or already done.
/// 3. A requirement must belong to the applicant's health case, and that case must exist.
///
/// The requirement is saved only after all three rules pass, through HealthRequirementRepository. This use case never talks to the database directly.
/// When a rule is broken, the screen shows the error's message and nothing is saved.

struct AddHealthRequirementUseCase {
    private let requirementRepository: HealthRequirementRepository
    private let caseRepository: HealthCaseRepository

    init(requirementRepository: HealthRequirementRepository,
         caseRepository: HealthCaseRepository) {
        self.requirementRepository = requirementRepository
        self.caseRepository = caseRepository
    }

    /// Adds the requirement to the applicant's health case.
    /// Throws AddHealthRequirementError/emptyTitle if the title is empty, AddHealthRequirementError/invalidDueDate if the due date is more than five years away, orAddHealthRequirementError/healthCaseNotFound if the applicant has no matching health case.
    func execute(_ requirement: HealthRequirement, now: Date = Date()) throws {
        // Rule 1: a title is required.
        let trimmedTitle = requirement.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw AddHealthRequirementError.emptyTitle
        }

        // Rule 2: the due date must be within five years before or after today.
        let calendar = Calendar.current
        let fiveYearsAgo = calendar.date(byAdding: .year, value: -5, to: now) ?? now
        let fiveYearsAhead = calendar.date(byAdding: .year, value: 5, to: now) ?? now
        if requirement.dueDate < fiveYearsAgo || requirement.dueDate > fiveYearsAhead {
            throw AddHealthRequirementError.invalidDueDate
        }

        // Rule 3: the health case must exist and match the requirement's case.
        guard let healthCase = try caseRepository.fetch(),
              healthCase.id == requirement.healthCaseID else {
            throw AddHealthRequirementError.healthCaseNotFound
        }

        // All rules passed, so save the requirement with the spaces removed from its title.
        var cleanedRequirement = requirement
        cleanedRequirement.title = trimmedTitle
        try requirementRepository.add(cleanedRequirement)
    }
}
