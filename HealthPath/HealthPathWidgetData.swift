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
        
        /// If there is a future appointment, show the next upcoming appointment.
        /// If there is no future appointment, show the next requirement and "No upcoming appointment."
        // Find the next future appointment all health requirement.
        let now = Date()
        
        let nextAppointment = appointments
            .filter { appointment in
                let isNotCompleted = !appointment.isCompleted
                let isInFuture = appointment.date >= now
                return isNotCompleted && isInFuture
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
