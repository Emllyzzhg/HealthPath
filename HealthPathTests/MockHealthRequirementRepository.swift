//
//  MockHealthRequirementRepository.swift
//  HealthPathTests
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
@testable import HealthPath

/// A pretend requirement store for tests. It keeps requirements in an array instead of Core Data.
final class MockHealthRequirementRepository: HealthRequirementRepository {

    var requirements: [HealthRequirement] = []

    func fetchAll() throws -> [HealthRequirement] {
        return requirements
    }

    func fetchRequirement(withID id: UUID) throws -> HealthRequirement? {
        for requirement in requirements {
            if requirement.id == id {
                return requirement
            }
        }
        return nil
    }

    func fetchUpcomingRequirements() throws -> [HealthRequirement] {
        var upcoming: [HealthRequirement] = []
        for requirement in requirements {
            if requirement.status != .completed {
                upcoming.append(requirement)
            }
        }
        return upcoming
    }

    func add(_ requirement: HealthRequirement) throws {
        requirements.append(requirement)
    }

    func update(_ requirement: HealthRequirement) throws {
        for index in 0..<requirements.count {
            if requirements[index].id == requirement.id {
                requirements[index] = requirement
                return
            }
        }
        throw HealthRequirementRepositoryError.requirementNotFound
    }

    func delete(_ requirement: HealthRequirement) throws {
        var remaining: [HealthRequirement] = []
        for existing in requirements {
            if existing.id != requirement.id {
                remaining.append(existing)
            }
        }
        requirements = remaining
    }
}
