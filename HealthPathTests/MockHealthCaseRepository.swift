//
//  MockHealthCaseRepository.swift
//  HealthPathTests
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
@testable import HealthPath

/// A pretend health case store for tests. It holds at most one case, like the real store.
final class MockHealthCaseRepository: HealthCaseRepository {
    var healthCase: HealthCase?

    func fetch() throws -> HealthCase? {
        return healthCase
    }

    func save(_ newCase: HealthCase) throws {
        if healthCase != nil {
            throw HealthCaseRepositoryError.healthCaseAlreadyExists
        }
        healthCase = newCase
    }
}
