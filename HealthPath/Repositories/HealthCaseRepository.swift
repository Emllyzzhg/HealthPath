//
//  HealthCaseRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import Foundation
/// Manages the user's health case.
/// Supports fetching and saving operations.
protocol HealthCaseRepository {
    func fetch() throws -> HealthCase?
    func save(_ healthCase: HealthCase) throws
}
