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
}
 
/// Provides timeline entries for the HealthPath widget.
struct HealthPathProvider: TimelineProvider {
    func placeholder(in context: Context) -> HealthPathEntry {
        HealthPathEntry(
            date: .now,
            requirementTitle: "Chest X-ray",
            dueDate: .now
        )
    }
 
    func getSnapshot(
        in context: Context,
        completion: @escaping (HealthPathEntry) -> Void
    ) {
        let entry = HealthPathEntry(
            date: .now,
            requirementTitle: "Chest X-ray",
            dueDate: .now
        )
        completion(entry)
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<HealthPathEntry>) -> Void
    ) {
        let entry = HealthPathEntry(
            date: .now,
            requirementTitle: "Chest X-ray",
            dueDate: .now
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
                if let dueDate = entry.dueDate {
                    Text(dueDate, style: .date)
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
                if let dueDate = entry.dueDate {
                    Text("Due \(dueDate, style: .date)")
                        .font(.subheadline)
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
        .description("View your next health requirement.")
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
        dueDate: .now
    )
}
#Preview("HealthPath - Medium", as: .systemMedium) {
    HealthPathWidget()
} timeline: {
    HealthPathEntry(
        date: .now,
        requirementTitle: "Specialist Appointment",
        dueDate: .now
    )
}
