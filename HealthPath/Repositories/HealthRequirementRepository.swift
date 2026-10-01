//
//  HealthRequirementRepository.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation
/// Keeps the applicant's own record of their health requirements.
/// Use cases talk to this protocol instead of the database, so the storage (Core Data in the app, a mock in unit tests) can change without affecting the business rules.
/// HealthPath stores the requirements the applicant records. It does not receive requirements from Home Affairs, eMedical or a clinic.

protocol HealthRequirementRepository {
    func fetchAll() throws -> [HealthRequirement]
    func fetchRequirement(withID id: UUID) throws -> HealthRequirement?
    func add(_ requirement: HealthRequirement) throws
    func update(_ requirement: HealthRequirement) throws
    func delete(_ requirement: HealthRequirement) throws
}

/// Problems the requirement store can report.
enum HealthRequirementRepositoryError: LocalizedError {
    /// The requirement is no longer stored, so it can't be changed.
    case requirementNotFound
    /// The health case could not be found, so the requirement can't be added to it.
    case healthCaseNotFound
    
    var errorDescription: String? {
        switch self {
        case .requirementNotFound:
            return "We couldn't find this health requirement. Go back to your requirements and try again."
        case .healthCaseNotFound:
            return "We couldn't find your health case. Go back to the start screen, tap Get Started, then add the requirement again."
        }
    }
}
