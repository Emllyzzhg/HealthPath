//
//  AppStartViewModel.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import Foundation
import Combine

/// Decides whether to show the welcome screen or the main app, and starts the applicant's health case when they tap Get Started.
@MainActor
final class AppStartViewModel: ObservableObject {

    /// The applicant's health case, or nil if they haven't started one yet.
    @Published private(set) var healthCase: HealthCase?

    /// A message for the applicant when something goes wrong, or nil when all is well.
    @Published var errorMessage: String?

    private let caseRepository: HealthCaseRepository

    init(caseRepository: HealthCaseRepository) {
        self.caseRepository = caseRepository
    }

    /// Checks whether the applicant has already started. Call this when the app opens.
    func load() {
        do {
            healthCase = try caseRepository.fetch()
            errorMessage = nil
        } catch {
            errorMessage = "We couldn't open your health case. Close the app and open it again. If it keeps happening, check that your phone has free storage."
        }
    }

    /// Starts the applicant's health case. If they already have one, it is used instead.
    func getStarted() {
        errorMessage = nil

        do {
            if let existingCase = try caseRepository.fetch() {
                healthCase = existingCase
                return
            }

            let newCase = HealthCase(id: UUID(), createdDate: Date())
            try caseRepository.save(newCase)
            healthCase = newCase
        } catch {
            if let repositoryError = error as? HealthCaseRepositoryError {
                errorMessage = repositoryError.errorDescription
            } else {
                errorMessage = "We couldn't get your health case started. Close the app and open it again, then try once more. If it keeps happening, check that your phone has free storage."
            }
        }
    }
}
