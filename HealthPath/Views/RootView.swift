//
//  RootView.swift
//  HealthPath
//
//  Created by emily zhang on 27/9/2026.
//

import SwiftUI

struct RootView: View {

    private let dependencies: AppDependencies
    @StateObject private var startViewModel: AppStartViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _startViewModel = StateObject(
            wrappedValue: AppStartViewModel(caseRepository: dependencies.caseRepository)
        )
    }

    var body: some View {
        Group {
            if startViewModel.healthCase != nil {
                mainTabs
            } else {
                OnboardingView(viewModel: startViewModel)
            }
        }
        .onAppear {
            startViewModel.load()
        }
    }

    /// The four main tabs, shown once the applicant has started their health case.
    private var mainTabs: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            Text("Requirements")
                .tabItem {
                    Label("Requirements", systemImage: "checklist")
                }

            Text("Appointments")
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }

            Text("Documents")
                .tabItem {
                    Label("Documents", systemImage: "doc.text")
                }
        }
    }
}

#Preview {
    RootView(
        dependencies: AppDependencies(
            context: PersistenceController(inMemory: true).container.viewContext
        )
    )
}
