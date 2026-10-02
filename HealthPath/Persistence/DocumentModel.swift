//
//  DocumentModel.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData

@Model
final class DocumentModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var filePath: String
    var dateAdded: Date
    var documentType: String

    var healthRequirement: HealthRequirementModel?

    init(
        id: UUID,
        name: String,
        filePath: String,
        dateAdded: Date,
        documentType: String
    ) {
        self.id = id
        self.name = name
        self.filePath = filePath
        self.dateAdded = dateAdded
        self.documentType = documentType
    }
}
