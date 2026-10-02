//
//  LocalHealthCaseRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
 
/// Sample health case data from a JSON file, for previews and tests.
final class LocalHealthCaseRepository: HealthCaseRepository {
    private var healthCase: HealthCase?
    private let fileURL: URL
    
    init() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        fileURL = documentsURL.appendingPathComponent("SampleHealthCase.json")
        
        // Copy the bundled JSON to Documents the first time
        if !fileManager.fileExists(atPath: fileURL.path) {
            if let bundledURL = Bundle.main.url(
                forResource: "SampleHealthCase",
                withExtension: "json"
            ) {
                try? fileManager.copyItem(
                    at: bundledURL,
                    to: fileURL
                )
            }
        }
        healthCase = load().first
    }
    
    func load() -> [HealthCase] {
        do {
            let data = try Data(contentsOf: fileURL)
 
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
 
            return try decoder.decode(
                [HealthCase].self,
                from: data
            )
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
        save()
    }
    
    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let cases = healthCase.map { [$0] } ?? []
            let data = try encoder.encode(cases)
            try data.write(
                to: fileURL,
                options: .atomic
            )
        } catch {
            print("Failed to save health case: \(error)")
        }
    }
}
