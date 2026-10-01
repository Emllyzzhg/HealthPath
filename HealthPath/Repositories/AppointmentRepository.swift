//
//  AppointmentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import Foundation
/// Keeps the applicant's own record of their health appointments.
/// Use cases talk to this protocol instead of the database, so the storage (Core Data in the app, a mock in unit tests) can change without affecting the business rules.
/// HealthPath stores appointments the applicant records. It does not book, change or cancel appointments with a clinic or Home Affairs.

protocol AppointmentRepository {
    func fetchAll() throws -> [Appointment]
    func fetchAppointments(for requirementID: UUID) throws -> [Appointment]
    func add(_ appointment: Appointment) throws
    func update(_ appointment: Appointment) throws
    func delete(_ appointment: Appointment) throws
}

/// Problems the appointment store can report.
enum AppointmentRepositoryError: LocalizedError {
    /// The appointment is no longer stored, so it can't be changed.
    case appointmentNotFound
    /// The health requirement could not be found, so the appointment can't be added to it.
    case requirementNotFound
    
    var errorDescription: String? {
        switch self {
        case .appointmentNotFound:
            return "We couldn't find this appointment. It may have been deleted. Go back to your appointments and try again."
        case .requirementNotFound:
            return "We couldn't find the health requirement for this appointment. Go back to your requirements, choose one, and try again."
        }
    }
}
