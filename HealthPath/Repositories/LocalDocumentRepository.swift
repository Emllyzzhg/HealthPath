//
//  LocalDocumentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation

/// Sample document data from a JSON file, for tests.
/// Every repository starts from the bundled file, and changes stay in memory, so tests never affect each other.
final class LocalDocumentRepository: DocumentRepository {

    private(set) var documents: [Document] = []

    init(fileName: String = "SampleDocuments") {
        documents = load(fileName: fileName)
    }

    private func load(fileName: String) -> [Document] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Could not find \(fileName).json in the app bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Document].self, from: data)
        } catch {
            print("Failed to load documents: \(error)")
            return []
        }
    }

    func fetchAll() throws -> [Document] {
        documents.sorted { $0.dateAdded > $1.dateAdded }
    }

    func fetchDocuments(for requirementID: UUID) throws -> [Document] {
        documents
            .filter { $0.healthRequirementID == requirementID }
            .sorted { $0.dateAdded > $1.dateAdded }
    }

    func add(_ document: Document) throws {
        documents.append(document)
    }

    func update(_ document: Document) throws {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else {
            throw DocumentRepositoryError.documentNotFound
        }
        documents[index] = document
    }

    func delete(_ document: Document) throws {
        documents.removeAll { $0.id == document.id }
    }
}
