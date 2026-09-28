//
//  Appointment.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation

struct Appointment: Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var location: String
    var descriptionText: String
    var isCompleted: Bool
    var healthRequirementID: UUID?
}
