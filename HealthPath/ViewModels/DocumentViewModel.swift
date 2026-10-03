//
//  DocumentViewModel.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import Combine
 
/// Manages the documents shown in the app.
/// It loads, adds and removes documents through the repository and use case.
@MainActor
final class DocumentViewModel: ObservableObject {
    
    @Published private(set) var documents: [Document] = []
    @Published var errorMessage: String?
    
    private let repository: any DocumentRepository
    private let addUseCase: AddDocumentUseCase
    
    init(
        documentRepository: any DocumentRepository,
        requirementRepository: any HealthRequirementRepository
    ) {
        repository = documentRepository
 
        addUseCase = AddDocumentUseCase(
            documentRepository: documentRepository,
            requirementRepository: requirementRepository
        )
    }
    
    /// Loads all saved documents.
    func loadDocuments() {
        do {
            documents = try repository.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Adds a document after its file has already been saved.
    @discardableResult
    func addDocument(_ document: Document) -> Bool {
        do {
            try addUseCase.execute(document)
            loadDocuments()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Removes a document from the saved document records.
    func deleteDocument(_ document: Document) {
        do {
            try repository.delete(document)
            loadDocuments()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
