//
//  AppointmentModel.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData

@Model
final class AppointmentModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var location: String
    var descriptionText: String
    var isCompleted: Bool

    var healthRequirement: HealthRequirementModel?

    init(
        id: UUID,
        title: String,
        date: Date,
        location: String,
        descriptionText: String,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
        self.descriptionText = descriptionText
        self.isCompleted = isCompleted
    }
}
