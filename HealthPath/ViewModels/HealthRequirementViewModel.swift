//
//  HealthRequirementViewModel.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
import Combine

/// Drives the Requirements screens: the list, adding a requirement and marking a requirement as completed.

@MainActor
final class HealthRequirementViewModel: ObservableObject {
    
    @Published private(set) var requirements: [HealthRequirement] = []
    @Published var selectedFilter: RequirementFilter = .all
    /// A message for the applicant when something goes wrong, or nil when all is well.
    @Published var errorMessage: String?
    
    private let repository: HealthRequirementRepository
    private let addUseCase: AddHealthRequirementUseCase
    private let completeUseCase: CompleteHealthRequirementUseCase
    private let healthCaseID: UUID
    
    init(
        requirementRepository: any HealthRequirementRepository,
        caseRepository: any HealthCaseRepository,
        healthCaseID: UUID
    ) {
        repository = requirementRepository
        addUseCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        completeUseCase = CompleteHealthRequirementUseCase(repository: requirementRepository)
        self.healthCaseID = healthCaseID
    }
    
    /// The requirements that match the filter the applicant has chosen.
    var filteredRequirements: [HealthRequirement] {
        var result: [HealthRequirement] = []
        for requirement in requirements {
            switch selectedFilter {
            case .all:
                result.append(requirement)
            case .incomplete:
                if requirement.status != .completed {
                    result.append(requirement)
                }
            case .completed:
                if requirement.status == .completed {
                    result.append(requirement)
                }
            }
        }
        return result
    }
    
    /// Loads the applicant's requirements. Call this when the screen appears.
    func loadRequirements() {
        do {
            requirements = try repository.fetchAll()
            let nextRequirement = requirements
                .filter { $0.status != .completed }
                .sorted { $0.dueDate < $1.dueDate }
                .first
            HealthPathWidgetData.save(requirement: nextRequirement)
            errorMessage = nil
        } catch {
            errorMessage = "We couldn't load your health requirements. Close the app and open it again. If it keeps happening, check that your phone has free storage."
        }
    }
    
    /// Adds a requirement to the applicant's health case.
    /// Returns true if it was saved, so the Add screen knows it can close.
    @discardableResult
    func add(title: String, descriptionText: String, dueDate: Date) -> Bool {
        errorMessage = nil
        
        let requirement = HealthRequirement(
            id: UUID(),
            title: title,
            descriptionText: descriptionText,
            dueDate: dueDate,
            status: .actionRequired,
            healthCaseID: healthCaseID
        )
        
        do {
            try addUseCase.execute(requirement)
            loadRequirements()
            return true
        } catch {
            if let addError = error as? AddHealthRequirementError {
                errorMessage = addError.errorDescription
            } else if let repositoryError = error as? HealthRequirementRepositoryError {
                errorMessage = repositoryError.errorDescription
            } else {
                errorMessage = "We couldn't save your requirement. Close the app and open it again, then try once more. If it keeps happening, check that your phone has free storage."
            }
            return false
        }
    }
    
    /// Marks a requirement as completed.
    func complete(id: UUID) {
        errorMessage = nil
        do {
            try completeUseCase.execute(id: id)
            loadRequirements()
        } catch {
            if let completeError = error as? CompleteHealthRequirementError {
                errorMessage = completeError.errorDescription
            } else if let repositoryError = error as? HealthRequirementRepositoryError {
                errorMessage = repositoryError.errorDescription
            } else {
                errorMessage = "We couldn't mark this requirement as completed. Close the app and open it again, then try once more."
            }
        }
    }
}
