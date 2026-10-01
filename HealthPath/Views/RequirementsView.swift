//
//  RequirementsView.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// The Requirements tab: the applicant's requirements, a filter and an Add button.
struct RequirementsView: View {

    @StateObject private var viewModel: HealthRequirementViewModel
    private let dependencies: AppDependencies
    @State private var showingAddRequirement = false

    init(viewModel: HealthRequirementViewModel, dependencies: AppDependencies) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.dependencies = dependencies
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Show", selection: $viewModel.selectedFilter) {
                    ForEach(RequirementFilter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                if viewModel.filteredRequirements.isEmpty {
                    ContentUnavailableView(
                        "No Requirements",
                        systemImage: "checklist",
                        description: Text(emptyMessage)
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredRequirements) { requirement in
                            NavigationLink {
                                RequirementDetailView(
                                    viewModel: dependencies.makeRequirementDetailViewModel(requirement: requirement),
                                    appointmentViewModel: dependencies.makeAppointmentViewModel()
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
                        }
                    }
                }
            }
            .navigationTitle("Requirements")
            .toolbar {
                Button {
                    showingAddRequirement = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add requirement")
            }
            .sheet(isPresented: $showingAddRequirement) {
                NavigationStack {
                    AddRequirementView(viewModel: viewModel)
                }
            }
            .onAppear {
                viewModel.loadRequirements()
            }
        }
    }

    /// What to show when the list has nothing in it, in the applicant's words.
    private var emptyMessage: String {
        switch viewModel.selectedFilter {
        case .all:
            return "Tap + to add the first thing you need to do, such as a medical examination or chest X-ray."
        case .incomplete:
            return "Nothing left to do. All your requirements are completed."
        case .completed:
            return "Completed requirements will appear here once you mark them as completed."
        }
    }
}
