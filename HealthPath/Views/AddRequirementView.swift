//
//  AddRequirementView.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// The form for adding a health requirement.
struct AddRequirementView: View {

    @ObservedObject var viewModel: HealthRequirementViewModel

    @Environment(\.dismiss) private var dismiss

    private let commonRequirements = [
        "Chest X-ray",
        "Specialist appointment",
        "Sputum test",
        "Blood test",
        "Video telehealth (VDOT)",
        "Medicine pickup",
        "Other"
    ]

    @State private var selectedTitle = "Chest X-ray"
    @State private var otherTitle = ""
    @State private var descriptionText = ""
    @State private var dueDate = Date()

    /// The title to save: the chosen requirement, or what the applicant typed for "Other".
    private var title: String {
        selectedTitle == "Other" ? otherTitle : selectedTitle
    }

    var body: some View {
        Form {
            Section("Requirement") {
                Picker("What do you need to do?", selection: $selectedTitle) {
                    ForEach(commonRequirements, id: \.self) { name in
                        Text(name).tag(name)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            if selectedTitle == "Other" {
                Section("Describe it") {
                    TextField("For example Vaccination", text: $otherTitle)
                }
            }
            
            Section("Details") {
                TextField(
                    "Details from your documents (optional)",
                    text: $descriptionText,
                    axis: .vertical
                )
            }
            
            Section {
                DatePicker(
                    "Due Date",
                    selection: $dueDate,
                    displayedComponents: .date
                )
            } header: {
                Text("Due Date")
            } footer: {
                Text("The date this requirement needs to be completed by, based on the follow-up instructions you received from the Chest Clinic.")
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Add Requirement")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.errorMessage = nil
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveRequirement()
                }
            }
        }
    }

    private func saveRequirement() {
        let saved = viewModel.add(
            title: title,
            descriptionText: descriptionText,
            dueDate: dueDate
        )

        if saved {
            dismiss()
        }
    }
}
