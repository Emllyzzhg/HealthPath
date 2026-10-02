//
//  HealthRequirementModel.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData
 
@Model
final class HealthRequirementModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var descriptionText: String
    var dueDate: Date
    var status: String
    var completedDate: Date?
    var healthCase: HealthCaseModel?
    
    @Relationship(deleteRule: .cascade, inverse: \AppointmentModel.healthRequirement)
    var appointments: [AppointmentModel] = []
    
    @Relationship(deleteRule: .cascade, inverse: \DocumentModel.healthRequirement)
    var documents: [DocumentModel] = []
 
    init(
        id: UUID,
        title: String,
        descriptionText: String,
        dueDate: Date,
        status: String,
        completedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.dueDate = dueDate
        self.status = status
        self.completedDate = completedDate
    }
}
