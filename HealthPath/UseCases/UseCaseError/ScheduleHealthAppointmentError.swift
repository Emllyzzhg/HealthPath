//
//  ScheduleHealthAppointmentError.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation

/// What can go wrong when an applicant schedules an appointment, in words they can act on.
/// Each case says what went wrong and what the applicant can do next. The message is shown on the Add Appointment screen.
/// See ScheduleHealthAppointmentUseCase for where each rule is checked.
enum ScheduleHealthAppointmentError: LocalizedError, Equatable {
    /// The appointment has no title. Enter a name such as "Chest X-ray".
    case emptyTitle
    /// The appointment date has already passed. Choose today or a later date, or check the date on your appointment letter.
    case appointmentInPast
    /// The health requirement this appointment belongs to could not be found. Go back to your requirements, choose one, and try again.
    case requirementNotFound

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "This appointment needs a title. Enter a name such as \"Chest X-ray\"."
        case .appointmentInPast:
            return "This appointment date has already passed. Choose today or a later date, or check the date on your appointment letter."
        case .requirementNotFound:
            return "We couldn't find the health requirement for this appointment. Go back to your requirements, choose one, and try again."
        }
    }
}
