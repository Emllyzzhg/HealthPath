//
//  RootView.swift
//  HealthPath
//
//  Created by emily zhang on 27/9/2026.
//

import SwiftUI
 
struct RootView: View {
    var body: some View {
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
    RootView()
}
 
