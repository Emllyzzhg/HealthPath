//
//  AddDocumentUseCase.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
 
/// Adds one of the applicant's health documents to a health requirement.
/// For example, an applicant can add a chest X-ray referral and keep it with their "Chest X-ray" requirement so they can find it later.
/// HealthPath keeps the applicant's own copy of the document. It does not send documents to Home Affairs or eMedical.
///
/// Business rules
/// 1. A document must have a name, such as "Chest X-ray referral".
/// 2. A document must have a saved file.
/// 3. A document must belong to a health requirement that exists.
///
/// The document is saved only after all three rules pass, through
/// DocumentRepository. This use case never talks to the database directly.
/// When a rule is broken, the screen shows the error's message and nothing is saved.
struct AddDocumentUseCase {
 
    private let documentRepository: DocumentRepository
    private let requirementRepository: HealthRequirementRepository
 
    init(
        documentRepository: DocumentRepository,
        requirementRepository: HealthRequirementRepository
    ) {
        self.documentRepository = documentRepository
        self.requirementRepository = requirementRepository
    }
    
    /// Adds the document to its health requirement.
    /// Throws an AddDocumentError when a business rule is not met.
    func execute(_ document: Document) throws {
        // Rule 1: a document name is required.
        let trimmedName = document.name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedName.isEmpty else {
            throw AddDocumentError.emptyName
        }
        
        // Rule 2: the document must have a saved file.
        let trimmedFilePath = document.filePath.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedFilePath.isEmpty else {
            throw AddDocumentError.emptyFile
        }
        
        // Rule 3: the health requirement must exist.
        let requirement = try requirementRepository.fetchRequirement(
            withID: document.healthRequirementID
        )
        guard requirement != nil else {
            throw AddDocumentError.requirementNotFound
        }
 
        // All rules passed, so save the document with the spaces removed from its title.
        var cleanedDocument = document
        cleanedDocument.name = trimmedName
        try documentRepository.add(cleanedDocument)
    }
}
