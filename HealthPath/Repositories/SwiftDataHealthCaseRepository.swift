//
//  SwiftDataHealthCaseRepository.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData
 
/// Keeps the applicant's health case in the app's SwiftData store.
/// This is the only place that talks to the database about the health case.
/// Use cases work through HealthCaseRepository, so the business rules never depend on SwiftData.
final class SwiftDataHealthCaseRepository: HealthCaseRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Returns the applicant's health case, or nil if they haven't started one yet.
    func fetch() throws -> HealthCase? {
        var descriptor = FetchDescriptor<HealthCaseModel>(
            sortBy: [SortDescriptor(\.createdDate)]
        )
        descriptor.fetchLimit = 1
        guard let model = try modelContext.fetch(descriptor).first else {
            return nil
        }
        return HealthCase(
            id: model.id,
            createdDate: model.createdDate
        )
    }
    
    /// Saves a new health case, for example when the applicant taps "Get Started".
    /// - Throws: HealthCaseRepositoryError.healthCaseAlreadyExists if the applicant already has a health case.
    func save(_ healthCase: HealthCase) throws {
        var descriptor = FetchDescriptor<HealthCaseModel>()
        descriptor.fetchLimit = 1
        if try modelContext.fetch(descriptor).first != nil {
            throw HealthCaseRepositoryError.healthCaseAlreadyExists
        }
        let model = HealthCaseModel(
            id: healthCase.id,
            createdDate: healthCase.createdDate
        )
        modelContext.insert(model)
        try modelContext.save()
    }
}
