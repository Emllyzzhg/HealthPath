//
//  LocalHealthRequirementRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
 
/// Sample requirement data from a JSON file, for previews and tests.
final class LocalHealthRequirementRepository: HealthRequirementRepository {
 
    private(set) var requirements: [HealthRequirement] = []
    private let fileURL: URL
 
    init() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        fileURL = documentsURL.appendingPathComponent("SampleRequirements.json")
 
        // Copy the bundled JSON to Documents the first time
        if !fileManager.fileExists(atPath: fileURL.path) {
            if let bundledURL = Bundle.main.url(
                forResource: "SampleRequirements",
                withExtension: "json"
            ) {
                try? fileManager.copyItem(
                    at: bundledURL,
                    to: fileURL
                )
            }
        }
        requirements = load()
    }
 
    func load() -> [HealthRequirement] {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(
                [HealthRequirement].self,
                from: data
            )
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
        save()
    }
 
    func update(_ requirement: HealthRequirement) throws {
        guard let index = requirements.firstIndex(
            where: { $0.id == requirement.id }
        ) else {
            throw HealthRequirementRepositoryError.requirementNotFound
        }
 
        requirements[index] = requirement
        save()
    }
 
    func delete(_ requirement: HealthRequirement) throws {
        requirements.removeAll { $0.id == requirement.id }
        save()
    }
 
    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
 
            let data = try encoder.encode(requirements)
 
            try data.write(
                to: fileURL,
                options: .atomic
            )
        } catch {
            print("Failed to save requirements: \(error)")
        }
    }
}
