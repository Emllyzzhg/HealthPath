//
//  HomeView.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// The Home tab: what the applicant needs to do next, and how far along they are.
struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel
    private let requirementRepository: any HealthRequirementRepository
    private let appointmentRepository: any AppointmentRepository

    init(viewModel: HomeViewModel,
         requirementRepository: any HealthRequirementRepository,
         appointmentRepository: any AppointmentRepository
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.requirementRepository = requirementRepository
        self.appointmentRepository = appointmentRepository
    }

    var body: some View {
        NavigationStack {
            List {
                if let message = viewModel.errorMessage {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }

                if viewModel.totalCount == 0 {
                    Section {
                        ContentUnavailableView(
                            "No Requirements Yet",
                            systemImage: "checklist",
                            description: Text(
                                "Open the Requirements tab and tap + to add the first thing you need to do."
                            )
                        )
                    }
                } else {
                    progressSection
                    nextActionSection
                    upcomingAppointmentSection
                    if !viewModel.recentActivity.isEmpty {
                        recentActivitySection
                    }
                }

                travellingSection
            }
            .navigationTitle(greeting)
            .onAppear {
                viewModel.load()
            }
        }
    }

    /// A greeting that matches the time of day.
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 18 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }

    private var progressSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(viewModel.completedCount) of \(viewModel.totalCount) completed")
                        .font(.title2)
                        .bold()

                    Spacer()

                    Text("\(Int(viewModel.progressFraction * 100))%")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: viewModel.progressFraction)
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
        } header: {
            Text("Your health requirements")
        }
    }

    private var nextActionSection: some View {
        Section {
            if let requirement = viewModel.nextAction {
                NavigationLink {
                    RequirementDetailView(
                        viewModel: RequirementDetailViewModel(
                            requirement: requirement,
                            requirementRepository: requirementRepository,
                            appointmentRepository: appointmentRepository,
                            completeUseCase: CompleteHealthRequirementUseCase(
                                repository: requirementRepository
                            )
                        ),
                        appointmentViewModel: AppointmentViewModel(
                            repository: appointmentRepository,
                            scheduleUseCase: ScheduleHealthAppointmentUseCase(
                                appointmentRepository: appointmentRepository,
                                requirementRepository: requirementRepository
                            )
                        )
                    )
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(requirement.title)
                            .font(.headline)
                        
                        if !requirement.descriptionText.isEmpty {
                            Text(requirement.descriptionText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text("Due \(requirement.dueDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                        RequirementStatusBadge(requirement: requirement)
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                }
            } else {
                Label("You've completed everything on your list.",systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        } header: {
            if let requirement = viewModel.nextAction {
                Text(requirement.isOverdue() ? "Overdue requirement" : "Next requirement")
            } else {
                Text("Next requirement")
            }
        }
    }
    
    private var upcomingAppointmentSection: some View {
        Section {
            if let appointment = viewModel.upcomingAppointment {
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
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            } else {
                Text("No upcoming appointments. Open a requirement and tap Add Appointment.")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Upcoming appointment")
        }
    }

    private var recentActivitySection: some View {
        Section {
            ForEach(viewModel.recentActivity) { requirement in
                VStack(alignment: .leading, spacing: 4) {
                    Label("\(requirement.title) completed", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    if let completedDate = requirement.completedDate {
                        Text(completedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
                .accessibilityElement(children: .combine)
            }
        } header: {
            Text("Recent activity")
        }
    }
    
    private var travellingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .accessibilityHidden(true)

                    Text("Travelling or moving?")
                        .font(.headline)
                }

                Text("If you are travelling interstate or overseas for an extended period, or moving to a new location, contact your health clinic or healthcare provider to let them know. They can advise you about any appointments, follow-up care or health requirements that may need to be updated.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Good to know")
        }
    }
}
