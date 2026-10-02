//
//  LocalAppointmentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
 
/// Sample appointment data from a JSON file, for previews and tests.
final class LocalAppointmentRepository: AppointmentRepository {
    
    private(set) var appointments: [Appointment] = []
    private let fileURL: URL
    
    init() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        fileURL = documentsURL.appendingPathComponent("SampleAppointments.json")
        
        // Copy the bundled JSON to Documents the first time
        if !fileManager.fileExists(atPath: fileURL.path) {
            if let bundleURL = Bundle.main.url(
                forResource: "SampleAppointments",
                withExtension: "json"
            ) {
                try? fileManager.copyItem(
                    at: bundleURL,
                    to: fileURL)
            }
        }
        appointments = load()
    }
    
    func load() -> [Appointment]{
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(
                [Appointment].self,
                from: data
            )
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
        guard let index = appointments.firstIndex(
            where: { $0.id == appointment.id }
        ) else {
            throw AppointmentRepositoryError.appointmentNotFound
        }
        appointments[index] = appointment
    }
    
    func delete(_ appointment: Appointment) throws {
        appointments.removeAll { $0.id == appointment.id }
    }
}
