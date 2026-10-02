//
//  AddDocumentError.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
 
/// What can go wrong when an applicant adds a health document.
/// Each case says what went wrong and what the applicant can do next.
/// The message is shown on the Add Document screen.
/// See AddDocumentUseCase for where each rule is checked.

enum AddDocumentError: LocalizedError, Equatable {
    /// The document has no name.
    case emptyName
    /// The document does not have a saved file.
    case emptyFile
    /// The health requirement this document belongs to could not be found.
    case requirementNotFound
 
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "This document needs a name. Enter a name such as \"Chest X-ray referral\"."
        case .emptyFile:
            return "This document doesn't have a file. Scan or choose a document and try again."
        case .requirementNotFound:
            return "We couldn't find the health requirement for this document. Go back to your requirements, choose one, and try again."
        }
    }
}
