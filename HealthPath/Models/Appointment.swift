//
//  Appointment.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation
/// A booked visit connected to one health requirement, such as a medical examination at a clinic or a telehealth specialist follow-up.
/// The applicant records the appointment so they can see when it is, where it is, and whether they have attended it. HealthPath keeps the applicant's own record. It does not book, change or cancel appointments with a clinic or Home Affairs.
///
/// Business rules
/// 1. An appointment must have a title, such as "Chest X-ray".
/// 2. An appointment must have a valid date.
/// 3. An appointment must belong to a health requirement that exists.
///
/// These rules are checked when the applicant schedules an appointment. See ScheduleHealthAppointmentUseCase

struct Appointment: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var location: String
    var descriptionText: String
    var isCompleted: Bool
    let healthRequirementID: UUID
}
