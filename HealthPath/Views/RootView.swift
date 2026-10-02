//
//  RootView.swift
//  HealthPath
//
//  Created by emily zhang on 27/9/2026.
//

import SwiftUI
 
struct RootView: View {
 
    private let caseRepository: any HealthCaseRepository
    private let requirementRepository: any HealthRequirementRepository
    private let appointmentRepository: any AppointmentRepository
    
    @StateObject private var startViewModel: AppStartViewModel
    
    init(
        caseRepository: any HealthCaseRepository,
        requirementRepository: any HealthRequirementRepository,
        appointmentRepository: any AppointmentRepository
    ) {
        self.caseRepository = caseRepository
        self.requirementRepository = requirementRepository
        self.appointmentRepository = appointmentRepository
        
        _startViewModel = StateObject(
            wrappedValue: AppStartViewModel(
                caseRepository: caseRepository
            )
        )
    }
    
    var body: some View {
        Group {
            if let healthCase = startViewModel.healthCase {
                mainTabs(healthCaseID: healthCase.id)
            } else {
                OnboardingView(viewModel: startViewModel)
            }
        }
        .onAppear {
            startViewModel.load()
        }
    }
    
    /// The four main tabs, shown once the applicant has started their health case.
    private func mainTabs(healthCaseID: UUID) -> some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView(
                    viewModel: HomeViewModel(
                        requirementRepository: requirementRepository,
                        appointmentRepository: appointmentRepository
                    ),
                    requirementRepository: requirementRepository,
                    appointmentRepository: appointmentRepository
                )
            }
            
            Tab("Requirements", systemImage: "checklist") {
                RequirementsView(
                    viewModel: HealthRequirementViewModel(
                        requirementRepository: requirementRepository,
                        caseRepository: caseRepository,
                        healthCaseID: healthCaseID
                    ),
                    requirementRepository: requirementRepository,
                    appointmentRepository: appointmentRepository
                )
            }
            
            Tab("Appointments", systemImage: "calendar") {
                AppointmentsView(
                    viewModel: AppointmentViewModel(
                        repository: appointmentRepository,
                        scheduleUseCase: ScheduleHealthAppointmentUseCase(
                            appointmentRepository: appointmentRepository,
                            requirementRepository: requirementRepository
                        )
                    )
                )
            }
            
            Tab("Documents", systemImage: "doc.text") {
                Text("Documents")
            }
        }
    }
}
