//
//  HealthCaseModel.swift
//  HealthPath
//
//  Created by emily zhang on 2/10/2026.
//

import Foundation
import SwiftData
 
@Model
final class HealthCaseModel {
    var id: UUID
    var createdDate: Date
 
    init(
        id: UUID,
        createdDate: Date
    ) {
        self.id = id
        self.createdDate = createdDate
    }
}
