//
//  HealthCaseRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import Foundation
/// Keeps the applicant's own record of their health case.
/// Use cases talk to this protocol instead of the database, so the storage (Swift Data in the app, a mock in unit tests) can change without affecting the business rules.
/// HealthPath keeps one health case for the applicant. It does not receive a case from Home Affairs or eMedical.
protocol HealthCaseRepository {
    func fetch() throws -> HealthCase?
    func save(_ healthCase: HealthCase) throws
}

/// Problems the health case store can report.
enum HealthCaseRepositoryError: LocalizedError {
    /// The applicant already has a health case, so a second one can't be started.
    case healthCaseAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .healthCaseAlreadyExists:
            return "You've already started your health case. Go to Home to continue."
        }
    }
}
