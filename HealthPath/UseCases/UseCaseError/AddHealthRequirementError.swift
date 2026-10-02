//
//  AddHealthRequirementError.swift
//  HealthPath
//
//  Created by emily zhang on 30/9/2026.
//

import Foundation

/// What can go wrong when an applicant adds a health requirement.
/// Each case says what went wrong and what the applicant can do next. The message is shown on the Add Requirement screen.
/// See AddHealthRequirementUseCase for where each rule is checked.
enum AddHealthRequirementError: LocalizedError, Equatable {
    /// The requirement has no title. Enter a name such as "Chest X-ray".
    case emptyTitle
    /// The due date is not valid, for example a year that is far too early or far too late. Check the date on your official documents and enter it again.
    case invalidDueDate
    /// The applicant's health case could not be found. Go back to the start screen and tap Get Started, then add the requirement again.
    case healthCaseNotFound

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "This requirement needs a title. Enter a name such as \"Chest X-ray\"."
        case .invalidDueDate:
            return "That due date doesn't look right. Check the date on your official documents and enter it again."
        case .healthCaseNotFound:
            return "We couldn't find your health case. Go back to the start screen, tap Get Started, then add the requirement again."
        }
    }
}
