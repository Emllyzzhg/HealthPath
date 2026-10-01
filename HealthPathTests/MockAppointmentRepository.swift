//
//  MockAppointmentRepository.swift
//  HealthPathTests
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
@testable import HealthPath

/// A pretend appointment store for tests. It keeps appointments in an array instead of Core Data.
final class MockAppointmentRepository: AppointmentRepository {

    var appointments: [Appointment] = []

    func fetchAll() throws -> [Appointment] {
        return appointments
    }

    func fetchAppointments(for requirementID: UUID) throws -> [Appointment] {
        var matching: [Appointment] = []
        for appointment in appointments {
            if appointment.healthRequirementID == requirementID {
                matching.append(appointment)
            }
        }
        return matching
    }

    func add(_ appointment: Appointment) throws {
        appointments.append(appointment)
    }

    func update(_ appointment: Appointment) throws {
        for index in 0..<appointments.count {
            if appointments[index].id == appointment.id {
                appointments[index] = appointment
                return
            }
        }
        throw AppointmentRepositoryError.appointmentNotFound
    }

    func delete(_ appointment: Appointment) throws {
        var remaining: [Appointment] = []
        for existing in appointments {
            if existing.id != appointment.id {
                remaining.append(existing)
            }
        }
        appointments = remaining
    }
}
