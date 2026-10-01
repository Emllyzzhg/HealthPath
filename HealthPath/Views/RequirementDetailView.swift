//
//  RequirementDetailView.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// Everything about one requirement in one place: its details, status, appointments, and the actions the applicant can take.
struct RequirementDetailView: View {

    @StateObject private var viewModel: RequirementDetailViewModel
    @StateObject private var appointmentViewModel: AppointmentViewModel

    @State private var showingAddAppointment = false
    @State private var showingCompleteConfirmation = false

    init(viewModel: RequirementDetailViewModel, appointmentViewModel: AppointmentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _appointmentViewModel = StateObject(wrappedValue: appointmentViewModel)
    }

    var body: some View {
        List {
            Section("Requirement") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.requirement.title)
                        .font(.headline)

                    if !viewModel.requirement.descriptionText.isEmpty {
                        Text(viewModel.requirement.descriptionText)
                            .font(.body)
                    }
                }
            }

            Section("Due Date") {
                HStack {
                    Image(systemName: "calendar")
                        .accessibilityHidden(true)

                    Text(viewModel.requirement.dueDate, style: .date)
                }
            }

            Section("Status") {
                RequirementStatusBadge(requirement: viewModel.requirement)
            }

            Section("Appointments") {
                if viewModel.appointments.isEmpty {
                    Text("No appointments yet. Add the date of your appointment for this requirement.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.appointments) { appointment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appointment.title)
                                .font(.headline)

                            Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)

                            if !appointment.location.isEmpty {
                                Text(appointment.location)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                        .accessibilityElement(children: .combine)
                    }
                }

                Button {
                    showingAddAppointment = true
                } label: {
                    Label("Add Appointment", systemImage: "plus.circle.fill")
                }
            }

            if let message = viewModel.errorMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }

            if viewModel.requirement.status != .completed {
                Section {
                    Button("Mark as completed") {
                        showingCompleteConfirmation = true
                    }
                }
            }
        }
        .navigationTitle("Requirement")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Mark this requirement as completed?",
            isPresented: $showingCompleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Mark as completed") {
                viewModel.complete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("It will move to your completed requirements.")
        }
        .sheet(isPresented: $showingAddAppointment, onDismiss: {
            viewModel.load()
        }) {
            NavigationStack {
                AddAppointmentView(
                    viewModel: appointmentViewModel,
                    healthRequirementID: viewModel.requirement.id,
                    requirementTitle: viewModel.requirement.title
                )
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}
