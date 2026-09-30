//
//  CoreDataAppointmentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import CoreData
/// Keeps the applicant's appointments in the app's Core Data store.
/// This is the only place that talks to the database about appointments. Use cases work through AppointmentRepository, so the business rules never depend on Core Data.
final class CoreDataAppointmentRepository: AppointmentRepository {
    
    private let context: NSManagedObjectContext
    /// The Core Data context used to read and save appointments
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    /// Returns every appointment the applicant has recorded, earliest first.
    /// Appointments that are not linked to a health requirement are left out.
    func fetchAll() throws -> [Appointment] {
        let request = AppointmentEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let entities = try context.fetch(request)
        
        var appointments: [Appointment] = []
        for entity in entities {
            guard let id = entity.id,
                  let date = entity.date,
                  let requirementID = entity.healthRequirement?.id else {
                continue
            }
            let appointment = Appointment(
                id: id,
                title: entity.title ?? "",
                date: entity.date ?? Date(),
                location: entity.location ?? "",
                descriptionText: entity.descriptionText ?? "",
                isCompleted: entity.isCompleted,
                healthRequirementID: requirementID
            )
            appointments.append(appointment)
        }
        return appointments
    }
    
    /// Returns the appointments recorded for one health requirement, earliest first.
    /// Parameter requirementID: The requirement, such as "Chest X-ray".
    func fetchAppointments(for requirementID: UUID) throws -> [Appointment] {
        let request = AppointmentEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "healthRequirement.id == %@",
            requirementID as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let entities = try context.fetch(request)
        
        var appointments: [Appointment] = []
        for entity in entities {
            guard let id = entity.id,
                  let date = entity.date,
                  let requirementID = entity.healthRequirement?.id else {
                continue
            }
            let appointment = Appointment(
                id: id,
                title: entity.title ?? "",
                date: entity.date ?? Date(),
                location: entity.location ?? "",
                descriptionText: entity.descriptionText ?? "",
                isCompleted: entity.isCompleted,
                healthRequirementID: requirementID
            )
            appointments.append(appointment)
        }
        return appointments
    }
    
    /// Saves a newly recorded appointment and links it to its health requirement.
    func add(_ appointment: Appointment) throws {
        let request = HealthRequirementEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            appointment.healthRequirementID as CVarArg
        )
        guard let requirementEntity = try context.fetch(request).first else {
            throw AppointmentRepositoryError.requirementNotFound
        }
        
        let entity = AppointmentEntity(context: context)
        entity.id = appointment.id
        entity.title = appointment.title
        entity.date = appointment.date
        entity.location = appointment.location
        entity.descriptionText = appointment.descriptionText
        entity.isCompleted = appointment.isCompleted
        entity.healthRequirement = requirementEntity

        try context.save()
    }
    
    /// Saves changes to an existing appointment, for example marking it as attended.
    /// Throws AppointmentRepositoryError/appointmentNotFound  if the appointment is no longer stored.
    func update(_ appointment: Appointment) throws {
        let request = AppointmentEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            appointment.id as CVarArg
        )
        guard let entity = try context.fetch(request).first else {
            throw AppointmentRepositoryError.appointmentNotFound
        }
        
        entity.title = appointment.title
        entity.date = appointment.date
        entity.location = appointment.location
        entity.descriptionText = appointment.descriptionText
        entity.isCompleted = appointment.isCompleted
        
        try context.save()
    }
    
    /// Removes an appointment the applicant no longer wants to keep.
    /// If the appointment can't be found, nothing changes.
    func delete(_ appointment: Appointment) throws {
        let request = AppointmentEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            appointment.id as CVarArg
        )
        
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
        }
    }
}
