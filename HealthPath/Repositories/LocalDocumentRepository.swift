//
//  LocalDocumentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
 
/// Sample document data from a JSON file, for previews and tests.
final class LocalDocumentRepository: DocumentRepository {
    private(set) var documents: [Document] = []
    private let fileURL: URL
    
    init() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        fileURL = documentsURL.appendingPathComponent("SampleDocuments.json")
        
        // Copy the bundled JSON to Documents the first time
        if !fileManager.fileExists(atPath: fileURL.path) {
            if let bundledURL = Bundle.main.url(
                forResource: "SampleDocuments",
                withExtension: "json"
            ) {
                try? fileManager.copyItem(
                    at: bundledURL,
                    to: fileURL
                )
            }
        }
        documents = load()
    }
    
    func load() -> [Document] {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(
                [Document].self,
                from: data
            )
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
        save()
    }
    
    func update(_ document: Document) throws {
        guard let index = documents.firstIndex(
            where: { $0.id == document.id }
        ) else {
            throw DocumentRepositoryError.documentNotFound
        }
        documents[index] = document
        save()
    }
    
    func delete(_ document: Document) throws {
        documents.removeAll { $0.id == document.id }
        save()
    }
    
    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(documents)
            try data.write(
                to: fileURL,
                options: .atomic
            )
        } catch {
            print("Failed to save documents: \(error)")
        }
    }
}
