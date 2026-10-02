//
//  LocalHealthRequirementRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation

/// Sample requirement data from a JSON file, for tests.
/// Every repository starts from the bundled file, and changes stay in memory, so tests never affect each other.
final class LocalHealthRequirementRepository: HealthRequirementRepository {

    private(set) var requirements: [HealthRequirement] = []
    private let now: Date

    /// now is passed in so the 7-day query gives the same result in every test.
    init(fileName: String = "SampleRequirements", now: Date = .now) {
        self.now = now
        requirements = load(fileName: fileName)
    }

    private func load(fileName: String) -> [HealthRequirement] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Could not find \(fileName).json in the app bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([HealthRequirement].self, from: data)
        } catch {
            print("Failed to load requirements: \(error)")
            return []
        }
    }

    func fetchAll() throws -> [HealthRequirement] {
        requirements.sorted { $0.dueDate < $1.dueDate }
    }

    func fetchRequirement(withID id: UUID) throws -> HealthRequirement? {
        requirements.first { $0.id == id }
    }

    func add(_ requirement: HealthRequirement) throws {
        requirements.append(requirement)
    }

    func update(_ requirement: HealthRequirement) throws {
        guard let index = requirements.firstIndex(where: { $0.id == requirement.id }) else {
            throw HealthRequirementRepositoryError.requirementNotFound
        }
        requirements[index] = requirement
    }

    func delete(_ requirement: HealthRequirement) throws {
        requirements.removeAll { $0.id == requirement.id }
    }
}
