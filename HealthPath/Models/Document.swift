//
//  Document.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation

/// The applicant's own copy of a health document, such as a referral or examination paperwork, kept with the health requirement it belongs to.
/// The applicant can scan a paper document in the app, or share one into HealthPath from another app. HealthPath keeps the applicant's copy so they can find it and share it when an organisation asks for it.
/// HealthPath does not send documents to Home Affairs or eMedical. Results, X-rays and specialist reports are handled by approved clinics, not by this app.
///
/// Business rules
/// 1. A document must have a name, such as "Medical Examination Receipt".
/// 2. A document must have a saved file. A document without a file cannot be added.
/// 3. A document must belong to a health requirement that exists.
///
/// These rules are checked when the applicant adds a document. See AddDocumentUseCase.

struct Document: Identifiable, Equatable, Hashable, Codable  {
    let id: UUID
    var name: String
    var filePath: String
    var dateAdded: Date
    var documentType: String
    var healthRequirementID: UUID
}
