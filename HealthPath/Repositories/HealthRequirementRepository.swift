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
enum HealthRequirementRepositoryError: Error {
    /// The requirement is no longer stored, so it can't be changed.
    case requirementNotFound
}
