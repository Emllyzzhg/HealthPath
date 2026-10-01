//
//  AppointmentsView.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// The Appointments tab: every appointment in date order, with its status.
struct AppointmentsView: View {

    @StateObject private var viewModel: AppointmentViewModel

    @State private var appointmentToDelete: Appointment?
    @State private var showingDeleteConfirmation = false

    init(viewModel: AppointmentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                if viewModel.appointments.isEmpty {
                    ContentUnavailableView(
                        "No Appointments",
                        systemImage: "calendar",
                        description: Text("To add one:\n1. Open the Requirements tab\n2. Tap a requirement\n3. Tap Add Appointment")
                    )
                } else {
                    List {
                        Section {
                            ForEach(viewModel.appointments) { appointment in
                                AppointmentRow(appointment: appointment)
                                    .swipeActions(edge: .leading) {
                                        if !appointment.isCompleted {
                                            Button {
                                                viewModel.markAsAttended(appointment)
                                            } label: {
                                                Label("Attended", systemImage: "checkmark.circle")
                                            }
                                            .tint(.green)
                                        }
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            appointmentToDelete = appointment
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                            }
                        } footer: {
                            Text("Swipe right to mark an appointment as attended. Swipe left to remove it.")
                        }
                    }
                }
            }
            .navigationTitle("Appointments")
            .confirmationDialog(
                "Remove this appointment?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    if let appointment = appointmentToDelete {
                        viewModel.delete(appointment)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("It will be taken out of your record. This can't be undone.")
            }
            .onAppear {
                viewModel.loadAppointments()
            }
        }
    }
}

/// One appointment in the list: what it is for, when, where, and its status.
struct AppointmentRow: View {

    let appointment: Appointment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(appointment.title)
                .font(.headline)

            Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)

            if !appointment.location.isEmpty {
                Text(appointment.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            AppointmentStatusBadge(appointment: appointment)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

/// Shows where an appointment is at, using an icon, words and a colour.
struct AppointmentStatusBadge: View {

    let appointment: Appointment

    var body: some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .foregroundStyle(colour)
    }

    private var text: String {
        if appointment.isCompleted {
            return "Attended"
        } else if appointment.date >= Date() {
            return "Upcoming"
        } else {
            return "Date passed"
        }
    }

    private var icon: String {
        if appointment.isCompleted {
            return "checkmark.circle.fill"
        } else if appointment.date >= Date() {
            return "clock"
        } else {
            return "calendar.badge.exclamationmark"
        }
    }

    private var colour: Color {
        if appointment.isCompleted {
            return .green
        } else if appointment.date >= Date() {
            return .orange
        } else {
            return .secondary
        }
    }
}
