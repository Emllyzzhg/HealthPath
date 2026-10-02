//
//  DocumentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import Foundation
/// Keeps the applicant's own record of their health documents.
/// Use cases talk to this protocol instead of the database, so the storage (Swift Data in the app, a mock in unit tests) can change without affecting the business rules.
/// HealthPath stores the applicant's copy of each document. It does not send documents to Home Affairs or eMedical.
protocol DocumentRepository {
    func fetchAll() throws -> [Document]
    func fetchDocuments(for requirementID: UUID) throws -> [Document]
    func add(_ document: Document) throws
    func update(_ document: Document) throws
    func delete(_ document: Document) throws
}

/// Problems the document store can report.
enum DocumentRepositoryError: LocalizedError {
    /// The document is no longer stored, so it can't be changed.
    case documentNotFound
    /// The health requirement could not be found, so the document can't be added to it.
    case requirementNotFound

    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "We couldn't find this document. It may have been deleted. Go back to your documents and try again."
        case .requirementNotFound:
            return "We couldn't find the health requirement for this document. Go back to your requirements, choose one, and try again."
        }
    }
}
