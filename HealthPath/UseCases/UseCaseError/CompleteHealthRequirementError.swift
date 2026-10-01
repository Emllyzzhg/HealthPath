//
//  CompleteHealthRequirementError.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation

/// What can go wrong when an applicant marks a health requirement as completed, in words they can act on.
/// Each case says what went wrong and what the applicant can do next. The message is shown on the Requirement Details screen.
/// See CompleteHealthRequirementUseCase for where each rule is checked.
enum CompleteHealthRequirementError: LocalizedError, Equatable {
    /// The requirement could not be found. Go back to your requirements and try again.
    case requirementNotFound
    /// The requirement is already marked as completed, so there is nothing more to do.
    case alreadyCompleted

    var errorDescription: String? {
        switch self {
        case .requirementNotFound:
            return "We couldn't find this health requirement. Go back to your requirements and try again."
        case .alreadyCompleted:
            return "This requirement is already marked as completed. You can find it under Completed requirements."
        }
    }
}
