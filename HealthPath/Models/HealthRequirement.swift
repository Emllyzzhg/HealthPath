//
//  HealthRequirement.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation

/// One health action an applicant needs to complete, such as a medical examination, a chest X-ray or a specialist follow-up.
/// A requirement is the centre of HealthPath. Its appointments and documents are kept with it, so the applicant can open "Chest X-ray" and see everything connected to it in one place.
/// HealthPath keeps the applicant's own record of what they have been asked to do.
/// It does not decide whether a requirement has been met, and it does not send anything to Home Affairs or eMedical.
///
/// Business rules
/// 1. A requirement must have a title, such as "Medical examination".
/// 2. A requirement must belong to the applicant's health case.
/// 3. A requirement must have a valid due date.
/// 4. A requirement that is already completed cannot be completed again.
/// 5. A requirement is overdue when it is not completed and its due date has passed. It is checked each time, so it is always right for today.
///
/// These rules are checked when the applicant adds or completes a requirement. See AddHealthRequirementUseCase and CompleteHealthRequirementUseCase.
/// 
struct HealthRequirement: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var descriptionText: String
    var dueDate: Date
    var status: HealthRequirementStatus
    let healthCaseID: UUID
    var completedDate: Date? = nil
    func isOverdue(at now: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return status != .completed
            && calendar.startOfDay(for: dueDate) < calendar.startOfDay(for: now)
    }
}
