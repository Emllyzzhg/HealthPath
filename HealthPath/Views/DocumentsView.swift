//
//  DocumentsView.swift
//  HealthPath
//
//  Created by emily zhang on 3/10/2026.
//

import SwiftUI

/// The Documents tab:
struct DocumentsView: View {
    
    @StateObject private var viewModel: DocumentViewModel
    @State private var showingAddDocument = false
    private let requirementRepository: any HealthRequirementRepository
    
    init(viewModel: DocumentViewModel,
         requirementRepository: any HealthRequirementRepository
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.requirementRepository = requirementRepository
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.documents.isEmpty {
                    ContentUnavailableView(
                        "No Documents",
                        systemImage: "doc.text",
                        description: Text(
                            "Your health documents will appear here."
                        )
                    )
                } else {
                    List {
                        ForEach(viewModel.documents) { document in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(document.name)
                                    .font(.headline)
 
                                Text(document.documentType)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
 
                                Text(document.dateAdded, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: deleteDocuments)
                    }
                }
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddDocument = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDocument){
                AddDocumentView(
                    viewModel: viewModel,
                    requirementRepository: requirementRepository
                )
            }
            .onAppear {
                viewModel.loadDocuments()
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { newValue in
                        if !newValue {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            let document = viewModel.documents[index]
            viewModel.deleteDocument(document)
        }
    }
}
