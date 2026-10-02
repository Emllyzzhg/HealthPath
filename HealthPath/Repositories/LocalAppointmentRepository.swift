//
//  LocalAppointmentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation

/// Sample appointment data from a JSON file, for tests.
/// Every repository starts from the bundled file, and changes stay in memory, so tests never affect each other.
final class LocalAppointmentRepository: AppointmentRepository {

    private(set) var appointments: [Appointment] = []

    init(fileName: String = "SampleAppointments") {
        appointments = load(fileName: fileName)
    }

    private func load(fileName: String) -> [Appointment] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Could not find \(fileName).json in the app bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Appointment].self, from: data)
        } catch {
            print("Failed to load appointments: \(error)")
            return []
        }
    }

    func fetchAll() throws -> [Appointment] {
        appointments.sorted { $0.date < $1.date }
    }

    func fetchAppointments(for requirementID: UUID) throws -> [Appointment] {
        appointments
            .filter { $0.healthRequirementID == requirementID }
            .sorted { $0.date < $1.date }
    }

    func add(_ appointment: Appointment) throws {
        appointments.append(appointment)
    }

    func update(_ appointment: Appointment) throws {
        guard let index = appointments.firstIndex(where: { $0.id == appointment.id }) else {
            throw AppointmentRepositoryError.appointmentNotFound
        }
        appointments[index] = appointment
    }

    func delete(_ appointment: Appointment) throws {
        appointments.removeAll { $0.id == appointment.id }
    }
}
