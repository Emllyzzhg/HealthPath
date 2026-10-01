//
//  OnboardingView.swift
//  HealthPath
//
//  Created by emily zhang on 1/10/2026.
//

import SwiftUI

/// The welcome screen, shown until the applicant starts their health case.
struct OnboardingView: View {

    @ObservedObject var viewModel: AppStartViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "cross.case")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Welcome")
                .font(.largeTitle)
                .bold()

            Text("Let's organise your health requirements")
                .font(.title3)
                .multilineTextAlignment(.center)

            Spacer()

            if let message = viewModel.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Get Started") {
                viewModel.getStarted()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
