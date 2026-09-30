//
//  HealthRequirementStatus.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation

/// The status helps the applicant see at a glance what still needs their attention.
/// It is the applicant's own record. It is not a decision from Home Affairs, and it does not say whether a requirement has been accepted.
/// "Overdue" is not stored as a status. It is worked out from the due date, so it is always correct for today.

enum HealthRequirementStatus: String {
    case upcoming
    case actionRequired
    case completed
}
