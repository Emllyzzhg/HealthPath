//
//  RequirementFilter.swift.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation

/// Which requirements the applicant wants to see on the Requirements screen.
enum RequirementFilter: CaseIterable {
    /// Every requirement, completed or not.
    case all
    /// Requirements the applicant still needs to complete.
    case incomplete
    /// Requirements the applicant has marked as completed.
    case completed

    /// The label shown on the filter control.
    var title: String {
        switch self {
        case .all: return "All"
        case .incomplete: return "Incomplete"
        case .completed: return "Completed"
        }
    }
}
