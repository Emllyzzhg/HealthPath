//
//  SwiftDataHealthRequirementRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData
 
/// Keeps the applicant's health requirements in the app's SwiftData store.
/// This is the only place that talks to the database about requirements.
/// Use cases work through HealthRequirementRepository, so the business rules never depend on SwiftData.
final class SwiftDataHealthRequirementRepository: HealthRequirementRepository {
    private let modelContext: ModelContext
    /// The SwiftData context used to read and save requirements.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Returns all health requirements the applicant has recorded, earliest first.
    func fetchAll() throws -> [HealthRequirement] {
        let descriptor = FetchDescriptor<HealthRequirementModel>(
            sortBy: [SortDescriptor(\.dueDate)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { model in
            makeHealthRequirement(from: model)
        }
    }
    
    /// Returns the requirement with this ID, or nil if it can't be found.
    /// - Parameter id: The requirement to look up.
    func fetchRequirement(withID id: UUID) throws -> HealthRequirement? {
        let requirementID = id
        let descriptor = FetchDescriptor<HealthRequirementModel>(
            predicate: #Predicate {
                $0.id == requirementID
            }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            return nil
        }
        return makeHealthRequirement(from: model)
    }
    
    /// Saves a newly recorded requirement and links it to the applicant's health case.
    /// - Throws: HealthRequirementRepositoryError.healthCaseNotFound if the case is not found.
    func add(_ requirement: HealthRequirement) throws {
        let healthCaseID = requirement.healthCaseID
        let caseDescriptor = FetchDescriptor<HealthCaseModel>(
            predicate: #Predicate {
                $0.id == healthCaseID
            }
        )
        guard try modelContext.fetch(caseDescriptor).first != nil else {
            throw HealthRequirementRepositoryError.healthCaseNotFound
        }
        let model = HealthRequirementModel(
            id: requirement.id,
            title: requirement.title,
            descriptionText: requirement.descriptionText,
            dueDate: requirement.dueDate,
            status: requirement.status.rawValue,
            healthCaseID: requirement.healthCaseID,
            completedDate: requirement.completedDate
        )
        modelContext.insert(model)
        try modelContext.save()
    }
    
    /// Saves changes to an existing requirement, for example marking it as completed.
    /// - Throws: HealthRequirementRepositoryError.requirementNotFound if the requirement is no longer stored.
    func update(_ requirement: HealthRequirement) throws {
        let requirementID = requirement.id
 
        let descriptor = FetchDescriptor<HealthRequirementModel>(
            predicate: #Predicate {
                $0.id == requirementID
            }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw HealthRequirementRepositoryError.requirementNotFound
        }
        model.title = requirement.title
        model.descriptionText = requirement.descriptionText
        model.dueDate = requirement.dueDate
        model.status = requirement.status.rawValue
        model.completedDate = requirement.completedDate
        try modelContext.save()
    }
    
    /// Removes a requirement the applicant no longer wants to keep.
    /// If the requirement can't be found, nothing changes.
    func delete(_ requirement: HealthRequirement) throws {
        let requirementID = requirement.id
 
        let descriptor = FetchDescriptor<HealthRequirementModel>(
            predicate: #Predicate {
                $0.id == requirementID
            }
        )
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
    
    private func makeHealthRequirement(
        from model: HealthRequirementModel
    ) -> HealthRequirement {
        HealthRequirement(
            id: model.id,
            title: model.title,
            descriptionText: model.descriptionText,
            dueDate: model.dueDate,
            status: HealthRequirementStatus(rawValue: model.status)
                ?? .actionRequired,
            healthCaseID: model.healthCaseID,
            completedDate: model.completedDate
        )
    }
}
