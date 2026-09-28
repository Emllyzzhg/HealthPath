//
//  HealthRequirementRepository.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation
 
protocol HealthRequirementRepository {
    func fetchAll() throws -> [HealthRequirement]
    func add(_ requirement: HealthRequirement) throws
    func update(_ requirement: HealthRequirement) throws
    func delete(_ requirement: HealthRequirement) throws
}
