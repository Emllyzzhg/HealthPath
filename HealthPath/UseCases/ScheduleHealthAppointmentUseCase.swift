//
//  ScheduleHealthAppointmentUseCase.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation

/// Records an appointment for one of the applicant's health requirements.
/// For example, an applicant with a chest X-ray requirement can record that they are attending a Specalist appointment on 14 October at 10:30 AM. The appointment then appears under that requirement and in the Appointments list.
/// HealthPath keeps the applicant's own record of their appointments. It does not book, change or cancel appointments with a clinic, Home Affairs or eMedical.
///
/// Business rules
/// 1. An appointment must have a title, such as "Chest X-ray".
/// 2. An appointment date and time cannot be in the past. Someone who attended before installing the app would instead add the requirement as completed and attach the documents.
/// 3. An appointment must belong to a health requirement that exists.
///
/// The appointment is saved only after all three rules pass, through AppointmentRepository. This use case never talks to the database directly.
/// When a rule is broken, the screen shows the error's message and nothing is saved.
struct ScheduleHealthAppointmentUseCase {
    private let appointmentRepository: AppointmentRepository
    private let requirementRepository: HealthRequirementRepository

    init(appointmentRepository: AppointmentRepository,
         requirementRepository: HealthRequirementRepository) {
        self.appointmentRepository = appointmentRepository
        self.requirementRepository = requirementRepository
    }

    /// Records the appointment for its health requirement.
    /// - Throws: ScheduleHealthAppointmentError/emptyTitle if the title is empty, ScheduleHealthAppointmentError/appointmentInPast if the date has already passed, or ScheduleHealthAppointmentError/requirementNotFound if the requirement does not exist.
    func execute(_ appointment: Appointment, now: Date = Date()) throws {
        // Rule 1: a title is required.
        let trimmedTitle = appointment.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            throw ScheduleHealthAppointmentError.emptyTitle
        }

        // Rule 2: the date and time cannot be in the past.
        if appointment.date < now {
            throw ScheduleHealthAppointmentError.appointmentInPast
        }

        // Rule 3: the health requirement must exist.
        let requirement = try requirementRepository.fetchRequirement(withID: appointment.healthRequirementID)
        if requirement == nil {
            throw ScheduleHealthAppointmentError.requirementNotFound
        }

        // All rules passed, so save the appointment with the spaces removed from its title.
        var cleanedAppointment = appointment
        cleanedAppointment.title = trimmedTitle
        try appointmentRepository.add(cleanedAppointment)
    }
}
