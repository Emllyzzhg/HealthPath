//
//  CoreDataHealthCaseRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import CoreData
/// Stores and manages the user's health case using Core Data.
final class CoreDataHealthCaseRepository: HealthCaseRepository {
 
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
 
    func fetch() throws -> HealthCase? {
        let request = HealthCaseEntity.fetchRequest()
        guard let entity = try context.fetch(request).first else {
            return nil
        }
        return HealthCase(
            id: entity.id ?? UUID(),
            createdDate: entity.createdDate ?? Date()
        )
    }
 
    func save(_ healthCase: HealthCase) throws {
        let request = HealthCaseEntity.fetchRequest()
        let entity: HealthCaseEntity
        if let existingEntity = try context.fetch(request).first {
            entity = existingEntity
        } else {
            entity = HealthCaseEntity(context: context)
        }
        entity.id = healthCase.id
        entity.createdDate = healthCase.createdDate
        try context.save()
    }
}
