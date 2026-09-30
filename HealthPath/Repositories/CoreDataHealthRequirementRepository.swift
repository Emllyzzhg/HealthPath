//
//  CoreDataHealthRequirementRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import CoreData
/// Keeps the applicant's health requirements in the app's Core Data store.
/// This is the only place that talks to the database about requirements.
/// Use cases work through HealthRequirementRepository, so the business rules never depend on Core Data.
final class CoreDataHealthRequirementRepository: HealthRequirementRepository {
 
    private let context: NSManagedObjectContext
    /// The Core Data context used to read and save requirements.
    init(context: NSManagedObjectContext) {
        self.context = context
    }
 
    func fetchAll() throws -> [HealthRequirement] {
        let request = HealthRequirementEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        let entities = try context.fetch(request)
        return entities.compactMap { entity in
            guard let id = entity.id,
                  let dueDate = entity.dueDate,
                  let healthCaseID = entity.healthCase?.id else {
                return nil
            }
            return HealthRequirement(
                id: id,
                title: entity.title ?? "",
                descriptionText: entity.descriptionText ?? "",
                dueDate: dueDate,
                status: HealthRequirementStatus(rawValue: entity.status ?? "") ?? .actionRequired,
                healthCaseID: healthCaseID
            )
        }
    }
    
    /// Returns the requirement with this ID, or nil if it can't be found.
    /// Parameter id: The requirement to look up.
    func fetchRequirement(withID id: UUID) throws -> HealthRequirement? {
        let request = HealthRequirementEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let entity = try context.fetch(request).first,
              let dueDate = entity.dueDate,
              let healthCaseID = entity.healthCase?.id else {
            return nil
        }

        return HealthRequirement(
            id: id,
            title: entity.title ?? "",
            descriptionText: entity.descriptionText ?? "",
            dueDate: dueDate,
            status: HealthRequirementStatus(rawValue: entity.status ?? "") ?? .actionRequired,
            healthCaseID: healthCaseID
        )
    }
    
    /// Saves a newly recorded requirement and links it to the applicant's health case.
    /// Throws: HealthRequirementRepositoryError/healthCaseNotFound if the case is not found.
    func add(_ requirement: HealthRequirement) throws {
        let request = HealthCaseEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            requirement.healthCaseID as CVarArg
        )
        guard let caseEntity = try context.fetch(request).first else {
            throw HealthRequirementRepositoryError.healthCaseNotFound
        }
        
        let entity = HealthRequirementEntity(context: context)
        entity.id = requirement.id
        entity.title = requirement.title
        entity.descriptionText = requirement.descriptionText
        entity.dueDate = requirement.dueDate
        entity.status = requirement.status.rawValue
        entity.healthCase = caseEntity

        try context.save()
    }
 
    /// Saves changes to an existing requirement, for example marking it as completed.
    /// Throws HealthRequirementRepositoryError/requirementNotFound if the requirement is no longer stored.
    func update(_ requirement: HealthRequirement) throws {
        let request = HealthRequirementEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            requirement.id as CVarArg
        )
        guard let entity = try context.fetch(request).first else {
            throw HealthRequirementRepositoryError.requirementNotFound
        }
        
        entity.title = requirement.title
        entity.descriptionText = requirement.descriptionText
        entity.dueDate = requirement.dueDate
        entity.status = requirement.status.rawValue
        try context.save()
    }
 
    /// Removes a requirement the applicant no longer wants to keep.
    /// If the requirement can't be found, nothing changes.
    func delete(_ requirement: HealthRequirement) throws {
        let request = HealthRequirementEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            requirement.id as CVarArg
        )
 
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
        }
    }
}
