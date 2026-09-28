//
//  Document.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation

struct Document: Identifiable {
    let id: UUID
    var name: String
    var filePath: String
    var dateAdded: Date
    var documentType: String
    var healthRequirementID: UUID?
}
