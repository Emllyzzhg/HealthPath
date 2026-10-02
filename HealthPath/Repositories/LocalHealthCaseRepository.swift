//
//  LocalHealthCaseRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation

/// Sample health case data from a JSON file, for tests.
/// Every repository starts from the bundled file, and changes stay in memory,
/// so tests never affect each other.
final class LocalHealthCaseRepository: HealthCaseRepository {

    private var healthCase: HealthCase?

    init(fileName: String = "SampleHealthCases") {
        healthCase = load(fileName: fileName).first
    }

    private func load(fileName: String) -> [HealthCase] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Could not find \(fileName).json in the app bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([HealthCase].self, from: data)
        } catch {
            print("Failed to load health case: \(error)")
            return []
        }
    }

    func fetch() throws -> HealthCase? {
        healthCase
    }

    func save(_ newCase: HealthCase) throws {
        if healthCase != nil {
            throw HealthCaseRepositoryError.healthCaseAlreadyExists
        }
        healthCase = newCase
    }
}
