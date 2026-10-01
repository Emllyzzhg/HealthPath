//
//  CoreDataHealthCaseRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import CoreData
/// Keeps the applicant's health case in the app's Core Data store.
/// This is the only place that talks to the database about the health case.
/// Use cases work through HealthCaseRepository, so the business rules never depend on Core Data.
final class CoreDataHealthCaseRepository: HealthCaseRepository {
 
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
 
    /// Returns the applicant's health case, or nil if they haven't started one yet.
    /// If the stored case is missing its id or start date, it is treated as not found.
    func fetch() throws -> HealthCase? {
        let request = HealthCaseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        request.fetchLimit = 1
        
        guard let entity = try context.fetch(request).first,
              let id = entity.id,
              let createdDate = entity.createdDate else {
            return nil
        }
        return HealthCase(
            id: id,
            createdDate: createdDate
        )
    }
 
    /// Saves a new health case, for example when the applicant taps "Get Started".
    /// - Throws: HealthCaseRepositoryError/healthCaseAlreadyExists if the applicant already has a health case.
    func save(_ healthCase: HealthCase) throws {
        let request = HealthCaseEntity.fetchRequest()
        request.fetchLimit = 1
        if try context.fetch(request).first != nil {
            throw HealthCaseRepositoryError.healthCaseAlreadyExists
        }
        let entity = HealthCaseEntity(context: context)
        entity.id = healthCase.id
        entity.createdDate = healthCase.createdDate
        try context.save()
    }
}
