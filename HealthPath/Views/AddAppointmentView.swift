//
//  AddAppointmentView.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// The form for recording an appointment for one requirement.
struct AddAppointmentView: View {

    @ObservedObject var viewModel: AppointmentViewModel
    let healthRequirementID: UUID

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var date = Date()
    @State private var location = ""
    @State private var descriptionText = ""

    init(viewModel: AppointmentViewModel, healthRequirementID: UUID, requirementTitle: String) {
        self.viewModel = viewModel
        self.healthRequirementID = healthRequirementID
        _title = State(initialValue: requirementTitle)
    }

    var body: some View {
        Form {
            Section("Appointment") {
                TextField("What is it for?", text: $title)

                DatePicker(
                    "Date and time",
                    selection: $date,
                    displayedComponents: [.date, .hourAndMinute]
                )

                TextField("Where is it? Clinic name or Telehealth", text: $location)
            }

            Section("Details") {
                TextField(
                    "Notes from your appointment letter (optional)",
                    text: $descriptionText,
                    axis: .vertical
                )
            }

            if let message = viewModel.errorMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Add Appointment")
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
                    saveAppointment()
                }
            }
        }
    }

    private func saveAppointment() {
        let saved = viewModel.schedule(
            title: title,
            date: date,
            location: location,
            descriptionText: descriptionText,
            healthRequirementID: healthRequirementID
        )

        if saved {
            dismiss()
        }
    }
}
