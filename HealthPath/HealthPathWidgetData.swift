//
//  Untitled.swift
//  HealthPath
//
//  Created by emily zhang on 4/10/2026.
//

import Foundation
import WidgetKit
 
/// Stores a small copy of the next health requirement and its related appointment in the local App Group container.
/// This allows the HealthPath app and HealthPath widget to access the same widget data.
/// The main requirement and appointment records remain stored in SwiftData.
struct HealthPathWidgetData {
 
    static let appGroup = "group.com.Assignment3.HealthPath"
 
    static func save(requirement: HealthRequirement?) {
        let sharedDefaults = UserDefaults(
            suiteName: appGroup
        )
 
        if let requirement {
            sharedDefaults?.set(
                requirement.id.uuidString,
                forKey: "nextRequirementID"
            )
 
            sharedDefaults?.set(
                requirement.title,
                forKey: "nextRequirementTitle"
            )
 
            sharedDefaults?.set(
                requirement.dueDate,
                forKey: "nextRequirementDueDate"
            )
        } else {
            sharedDefaults?.removeObject(
                forKey: "nextRequirementID"
            )
 
            sharedDefaults?.removeObject(
                forKey: "nextRequirementTitle"
            )
 
            sharedDefaults?.removeObject(
                forKey: "nextRequirementDueDate"
            )
 
            sharedDefaults?.removeObject(
                forKey: "nextAppointmentTitle"
            )
 
            sharedDefaults?.removeObject(
                forKey: "nextAppointmentDate"
            )
        }
 
        WidgetCenter.shared.reloadAllTimelines()
    }
 
    static func save(appointments: [Appointment]) {
        let sharedDefaults = UserDefaults(
            suiteName: appGroup
        )
 
        guard
            let requirementIDString = sharedDefaults?.string(
                forKey: "nextRequirementID"
            ),
            let requirementID = UUID(
                uuidString: requirementIDString
            )
        else {
            return
        }
 
        let nextAppointment = appointments
            .filter {
                $0.healthRequirementID == requirementID && !$0.isCompleted
            }
            .sorted { $0.date < $1.date }
            .first
 
        if let nextAppointment {
            sharedDefaults?.set(
                nextAppointment.title,
                forKey: "nextAppointmentTitle"
            )
 
            sharedDefaults?.set(
                nextAppointment.date,
                forKey: "nextAppointmentDate"
            )
        } else {
            sharedDefaults?.removeObject(
                forKey: "nextAppointmentTitle"
            )
 
            sharedDefaults?.removeObject(
                forKey: "nextAppointmentDate"
            )
        }
 
        WidgetCenter.shared.reloadAllTimelines()
    }
}
