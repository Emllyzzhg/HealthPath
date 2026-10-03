//
//  HealthPathWidget.swift
//  HealthPathWidget
//
//  Created by emily zhang on 3/10/2026.
//

import WidgetKit
import SwiftUI
 
/// Represents the information displayed by the HealthPath widget.
struct HealthPathEntry: TimelineEntry {
    let date: Date
    let requirementTitle: String
    let dueDate: Date?
    let appointmentTitle: String?
    let appointmentDate: Date?
}
 
/// Provides timeline entries for the HealthPath widget.
struct HealthPathProvider: TimelineProvider {
    func placeholder(in context: Context) -> HealthPathEntry {
        HealthPathEntry(
            date: .now,
            requirementTitle: "Chest X-ray",
            dueDate: .now,
            appointmentTitle: "Chest X-ray Appointment",
            appointmentDate: .now
        )
    }
 
    func getSnapshot(
        in context: Context,
        completion: @escaping (HealthPathEntry) -> Void
    ) {
        let entry = HealthPathEntry(
            date: .now,
            requirementTitle: "Chest X-ray",
            dueDate: .now,
            appointmentTitle: "Chest X-ray Appointment",
            appointmentDate: .now
        )
        completion(entry)
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<HealthPathEntry>) -> Void
    ) {
        let sharedDefaults = UserDefaults(
            suiteName: "group.com.Assignment3.HealthPath"
        )
        let requirementTitle = sharedDefaults?.string(
            forKey: "nextRequirementTitle"
        ) ?? "No upcoming requirements"
        let dueDate = sharedDefaults?.object(
            forKey: "nextRequirementDueDate"
        ) as? Date
        let appointmentTitle = sharedDefaults?.string(
            forKey: "nextAppointmentTitle"
        )
        let appointmentDate = sharedDefaults?.object(
            forKey: "nextAppointmentDate"
        ) as? Date
        
        let entry = HealthPathEntry(
            date: .now,
            requirementTitle: requirementTitle,
            dueDate: dueDate,
            appointmentTitle: appointmentTitle,
            appointmentDate: appointmentDate
        )
        
        let timeline = Timeline(
            entries: [entry],
            policy: .never
        )
        completion(timeline)
    }
}
 
/// Displays HealthPath information based on the widget size.
struct HealthPathWidgetView: View {
    var entry: HealthPathEntry
    
    @Environment(\.widgetFamily) private var family
    
    var body: some View {
        if family == .systemSmall {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "heart.text.clipboard")
                Text("Next Requirement")
                    .font(.caption)
                Text(entry.requirementTitle)
                    .font(.headline)
                if let appointmentDate = entry.appointmentDate {
                    Text("Appointment")
                        .font(.caption)
                    Text(appointmentDate, style: .date)
                        .font(.caption)
                    Text(appointmentDate, style: .time)
                        .font(.caption)
                }
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        } else if family == .systemMedium {
            VStack(alignment: .leading, spacing: 8) {
                Label(
                    "Next Health Requirement",
                    systemImage: "heart.text.clipboard"
                )
                .font(.headline)
                Text(entry.requirementTitle)
                    .font(.title3)
                if let appointmentDate = entry.appointmentDate {
                    Text("Appointment: \(appointmentDate, style: .date)")
                        .font(.subheadline)
                    Text(appointmentDate, style: .time)
                        .font(.subheadline)
                } else {
                    Text("No appointment scheduled")
                        .font(.subheadline)
                }
                if let dueDate = entry.dueDate {
                    Text("Due Date: \(dueDate, style: .date)")
                        .font(.caption)
                }
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        } else {
            Text("Something Went Wrong")
        }
    }
}
 
/// The HealthPath home-screen widget.
struct HealthPathWidget: Widget {
    let kind: String = "HealthPathWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: HealthPathProvider()
        ) { entry in
            HealthPathWidgetView(entry: entry)
                .containerBackground(
                    .fill.tertiary,
                    for: .widget
                )
        }
        .configurationDisplayName("HealthPath")
        .description("View your next health requirement and appointment.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
    }
}

#Preview("HealthPath - Small", as: .systemSmall) {
    HealthPathWidget()
} timeline: {
    HealthPathEntry(
        date: .now,
        requirementTitle: "Chest X-ray",
        dueDate: .now,
        appointmentTitle: "Chest X-ray Appointment",
        appointmentDate: .now
    )
}
#Preview("HealthPath - Medium", as: .systemMedium) {
    HealthPathWidget()
} timeline: {
    HealthPathEntry(
        date: .now,
        requirementTitle: "Specialist Appointment",
        dueDate: .now,
        appointmentTitle: "Sputum Test Appointment",
        appointmentDate: .now
    )
}
