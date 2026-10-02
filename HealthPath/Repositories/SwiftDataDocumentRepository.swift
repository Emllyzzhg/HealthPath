//
//  SwiftDataDocumentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData
 
/// Keeps the applicant's health documents in the app's SwiftData store.
/// This is the only place that talks to the database about documents.
/// Use cases work through DocumentRepository, so the business rules never depend on SwiftData.
/// The database keeps each document's details and the name of its saved file.
/// The file itself is stored separately on the device.
final class SwiftDataDocumentRepository: DocumentRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    /// Returns the documents the applicant has added, newest first.
    func fetchAll() throws -> [Document] {
        let descriptor = FetchDescriptor<DocumentModel>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.compactMap { model in makeDocument(from: model)
        }
    }
    
    /// Returns the documents kept with one health requirement, newest first.
    /// - Parameter requirementID: The requirement, such as "Chest X-ray".
    func fetchDocuments(for requirementID: UUID) throws -> [Document] {
        let selectedRequirementID = requirementID
        let descriptor = FetchDescriptor<DocumentModel>(
            predicate: #Predicate {
                $0.healthRequirement?.id == selectedRequirementID
            },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.compactMap { model in makeDocument(from: model)
        }
    }
    
    /// Saves a newly added document and links it to its health requirement.
    /// - Throws: DocumentRepositoryError.requirementNotFound if the health requirement does not exist.
    func add(_ document: Document) throws {
        let requirementID = document.healthRequirementID
        let requirementDescriptor = FetchDescriptor<HealthRequirementModel>(
            predicate: #Predicate {
                $0.id == requirementID
            }
        )
        guard let requirementModel = try modelContext.fetch(requirementDescriptor).first else {
            throw DocumentRepositoryError.requirementNotFound
        }
        let model = DocumentModel(
            id: document.id,
            name: document.name,
            filePath: document.filePath,
            dateAdded: document.dateAdded,
            documentType: document.documentType
        )
        modelContext.insert(model)
        model.healthRequirement = requirementModel
        try modelContext.save()
    }
    
    /// Saves changes to an existing document, for example a new name.
    /// A document stays with the requirement it was added to, and its date added does not change.
    /// - Throws: DocumentRepositoryError.documentNotFound if the document is no longer stored.
    func update(_ document: Document) throws {
        let documentID = document.id
        let descriptor = FetchDescriptor<DocumentModel>(
            predicate: #Predicate {
                $0.id == documentID
            }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw DocumentRepositoryError.documentNotFound
        }
        model.name = document.name
        model.filePath = document.filePath
        model.documentType = document.documentType
        try modelContext.save()
    }
    
    /// Removes a document the applicant no longer wants to keep.
    /// The saved file is not removed here.
    /// If the document can't be found, nothing changes.
    func delete(_ document: Document) throws {
        let documentID = document.id
        let descriptor = FetchDescriptor<DocumentModel>(
            predicate: #Predicate {
                $0.id == documentID
            }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
    
    private func makeDocument(from model: DocumentModel) -> Document? {
        guard let requirementID = model.healthRequirement?.id else {
            return nil
        }
        return Document(
            id: model.id,
            name: model.name,
            filePath: model.filePath,
            dateAdded: model.dateAdded,
            documentType: model.documentType,
            healthRequirementID: requirementID
        )
    }
}
