//
//  SwiftDataAppointmentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData
 
/// Keeps the applicant's appointments in the app's SwiftData store.
/// This is the only place that talks to the database about appointments.
/// Use cases work through AppointmentRepository, so the business rules never depend on SwiftData.
final class SwiftDataAppointmentRepository: AppointmentRepository {
    private let modelContext: ModelContext
    
    /// The SwiftData context used to read and save appointments.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Returns every appointment the applicant has recorded, earliest first.
    func fetchAll() throws -> [Appointment] {
        let descriptor = FetchDescriptor<AppointmentModel>(
            sortBy: [SortDescriptor(\.date)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { model in
            makeAppointment(from: model)
        }
    }
    
    /// Returns the appointments recorded for one health requirement, earliest first.
    /// - Parameter requirementID: The requirement, such as "Chest X-ray".
    func fetchAppointments(for requirementID: UUID) throws -> [Appointment] {
        let selectedRequirementID = requirementID
        let descriptor = FetchDescriptor<AppointmentModel>(
            predicate: #Predicate {
                $0.healthRequirementID == selectedRequirementID
            },
            sortBy: [SortDescriptor(\.date)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { model in
            makeAppointment(from: model)
        }
    }
    
    /// Saves a newly recorded appointment and links it to its health requirement.
    func add(_ appointment: Appointment) throws {
        let requirementID = appointment.healthRequirementID
 
        let requirementDescriptor = FetchDescriptor<HealthRequirementModel>(
            predicate: #Predicate {
                $0.id == requirementID
            }
        )
        guard try modelContext.fetch(requirementDescriptor).first != nil else {
            throw AppointmentRepositoryError.requirementNotFound
        }
 
        let model = AppointmentModel(
            id: appointment.id,
            title: appointment.title,
            date: appointment.date,
            location: appointment.location,
            descriptionText: appointment.descriptionText,
            isCompleted: appointment.isCompleted,
            healthRequirementID: appointment.healthRequirementID
        )
        modelContext.insert(model)
        try modelContext.save()
    }
    
    /// Saves changes to an existing appointment, for example marking it as attended.
    /// - Throws: AppointmentRepositoryError.appointmentNotFound if the appointment is no longer stored.
    func update(_ appointment: Appointment) throws {
        let appointmentID = appointment.id
        let descriptor = FetchDescriptor<AppointmentModel>(
            predicate: #Predicate {
                $0.id == appointmentID
            }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw AppointmentRepositoryError.appointmentNotFound
        }
        
        model.title = appointment.title
        model.date = appointment.date
        model.location = appointment.location
        model.descriptionText = appointment.descriptionText
        model.isCompleted = appointment.isCompleted
        
        try modelContext.save()
    }
    
    /// Removes an appointment the applicant no longer wants to keep.
    /// If the appointment can't be found, nothing changes.
    func delete(_ appointment: Appointment) throws {
        let appointmentID = appointment.id
 
        let descriptor = FetchDescriptor<AppointmentModel>(
            predicate: #Predicate {
                $0.id == appointmentID
            }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
    
    private func makeAppointment(
        from model: AppointmentModel
    ) -> Appointment {
        Appointment(
            id: model.id,
            title: model.title,
            date: model.date,
            location: model.location,
            descriptionText: model.descriptionText,
            isCompleted: model.isCompleted,
            healthRequirementID: model.healthRequirementID
        )
    }
}
