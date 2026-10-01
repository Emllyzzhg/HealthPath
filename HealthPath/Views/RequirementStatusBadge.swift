//
//  RequirementStatusBadge.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// Shows where a requirement is at, using an icon, words and a colour.
struct RequirementStatusBadge: View {

    let requirement: HealthRequirement

    var body: some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .foregroundColor(colour)
    }

    private var text: String {
        if requirement.isOverdue() {
            return "Overdue"
        } else if requirement.status == .completed {
            return "Completed"
        } else if requirement.status == .upcoming {
            return "Upcoming"
        } else {
            return "Action required"
        }
    }

    private var icon: String {
        if requirement.isOverdue() {
            return "exclamationmark.circle.fill"
        } else if requirement.status == .completed {
            return "checkmark.circle.fill"
        } else if requirement.status == .upcoming {
            return "clock"
        } else {
            return "exclamationmark.triangle"
        }
    }

    private var colour: Color {
        if requirement.isOverdue() {
            return .red
        } else if requirement.status == .completed {
            return .green
        } else {
            return .orange
        }
    }
}
