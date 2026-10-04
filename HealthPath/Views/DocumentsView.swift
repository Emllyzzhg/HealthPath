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
    @State private var sharedDocumentPath: String?
    @State private var sharedDocumentName: String?
    @State private var requirements: [HealthRequirement] = []
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
                            NavigationLink {
                                DocumentDetailView(document: document)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(document.name)
                                        .font(.headline)
                                    
                                    Text(requirementName(for: document))
                                        .font(.subheadline)
                                    
                                    Text(document.documentType)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(document.dateAdded, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
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
                        sharedDocumentPath = nil
                        sharedDocumentName = nil
                        showingAddDocument = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDocument){
                AddDocumentView(
                    viewModel: viewModel,
                    requirementRepository: requirementRepository,
                    sharedDocumentPath: sharedDocumentPath,
                    sharedDocumentName: sharedDocumentName
                )
            }
            .onAppear {
                viewModel.loadDocuments()
                loadRequirements()
                loadSharedDocument()
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
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
    
    private func loadSharedDocument() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.Assignment3.HealthPath")
        guard let filePath = sharedDefaults?.string(
            forKey: "sharedDocumentPath"
        ) else {
            return
        }
        sharedDocumentPath = filePath
        sharedDocumentName = sharedDefaults?.string(
            forKey: "sharedDocumentName"
        )
        showingAddDocument = true
    }
    
    private func loadRequirements() {
        do {
            requirements = try requirementRepository.fetchAll()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
    
    private func requirementName(for document: Document) -> String {
        let requirement = requirements.first {
            $0.id == document.healthRequirementID
        }
        return requirement?.title ?? "Unknown Requirement"
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            let document = viewModel.documents[index]
            viewModel.deleteDocument(document)
        }
    }
}
