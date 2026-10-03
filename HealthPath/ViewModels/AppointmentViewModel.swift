//
//  AppointmentViewModel.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
import Combine

/// Drives the Appointments screens: the chronological list, scheduling an appointment for a requirement and removing an appointment.
@MainActor
final class AppointmentViewModel: ObservableObject {

    @Published private(set) var appointments: [Appointment] = []
    /// A message for the applicant when something goes wrong, or nil when all is well.
    @Published var errorMessage: String?

    private let repository: AppointmentRepository
    private let scheduleUseCase: ScheduleHealthAppointmentUseCase

    init(
        repository: AppointmentRepository,
        scheduleUseCase: ScheduleHealthAppointmentUseCase
    ) {
        self.repository = repository
        self.scheduleUseCase = scheduleUseCase
    }

    /// Loads the applicant's appointments, earliest first. Call this when the screen appears.
    func loadAppointments() {
        do {
            appointments = try repository.fetchAll()
            HealthPathWidgetData.save(appointments: appointments)
            errorMessage = nil
        } catch {
            errorMessage = "We couldn't load your appointments. Close the app and open it again. If it keeps happening, check that your phone has free storage."
        }
    }

    /// Records an appointment for a health requirement. Returns true if it was saved, so the Add screen knows it can close.
    @discardableResult
    func schedule(
        title: String,
        date: Date,
        location: String,
        descriptionText: String,
        healthRequirementID: UUID
    ) -> Bool {
        errorMessage = nil

        let appointment = Appointment(
            id: UUID(),
            title: title,
            date: date,
            location: location,
            descriptionText: descriptionText,
            isCompleted: false,
            healthRequirementID: healthRequirementID
        )

        do {
            try scheduleUseCase.execute(appointment)
            loadAppointments()
            return true
        } catch {
            if let scheduleError = error as? ScheduleHealthAppointmentError {
                errorMessage = scheduleError.errorDescription
            } else if let repositoryError = error as? AppointmentRepositoryError {
                errorMessage = repositoryError.errorDescription
            } else {
                errorMessage = "We couldn't save your appointment. Close the app and open it again, then try once more. If it keeps happening, check that your phone has free storage."
            }
            return false
        }
    }

    /// Removes an appointment the applicant no longer wants to keep.
    func delete(_ appointment: Appointment) {
        errorMessage = nil

        do {
            try repository.delete(appointment)
            loadAppointments()
        } catch {
            errorMessage = "We couldn't remove this appointment. Close the app and open it again, then try once more."
        }
    }
    
    /// Marks an appointment as attended.
    func markAsAttended(_ appointment: Appointment) {
        errorMessage = nil

        var attendedAppointment = appointment
        attendedAppointment.isCompleted = true

        do {
            try repository.update(attendedAppointment)
            loadAppointments()
            // Once the widget exists, reload it here: WidgetCenter.shared.reloadAllTimelines()
        } catch {
            if let repositoryError = error as? AppointmentRepositoryError {
                errorMessage = repositoryError.errorDescription
            } else {
                errorMessage = "We couldn't mark this appointment as attended. Close the app and open it again, then try once more."
            }
        }
    }
}
