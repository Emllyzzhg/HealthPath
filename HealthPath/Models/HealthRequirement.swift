//
//  HealthRequirement.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation
 
struct HealthRequirement: Identifiable {
    let id: UUID
    var title: String
    var descriptionText: String
    var dueDate: Date
    var status: String
}
