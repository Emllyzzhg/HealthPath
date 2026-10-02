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
    var id: UUID
    var title: String
    var descriptionText: String
    var dueDate: Date
    var status: String
    var healthCaseID: UUID
    var completedDate: Date?
 
    init(
        id: UUID,
        title: String,
        descriptionText: String,
        dueDate: Date,
        status: String,
        healthCaseID: UUID,
        completedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.dueDate = dueDate
        self.status = status
        self.healthCaseID = healthCaseID
        self.completedDate = completedDate
    }
}
