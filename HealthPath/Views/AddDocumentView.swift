//
//  AddDocumentView.swift
//  HealthPath
//
//  Created by emily zhang on 3/10/2026.
//

import SwiftUI
 
/// Lets the applicant add a health document and attach it to a health requirement.
struct AddDocumentView: View {
    @Environment(\.dismiss) private var dismiss
 
    @ObservedObject var viewModel: DocumentViewModel
 
    private let requirementRepository: any HealthRequirementRepository
    private let sharedDocumentPath: String?
    private let sharedDocumentName: String?
 
    @State private var name = ""
    @State private var documentType = ""
    @State private var requirements: [HealthRequirement] = []
    @State private var selectedRequirementID: UUID?
 
    @State private var scannedPDFData: Data?
    @State private var showingScanner = false
    @State private var errorMessage: String?
 
    init(
        viewModel: DocumentViewModel,
        requirementRepository: any HealthRequirementRepository,
        sharedDocumentPath: String? = nil,
        sharedDocumentName: String? = nil
    ) {
        self.viewModel = viewModel
        self.requirementRepository = requirementRepository
        self.sharedDocumentPath = sharedDocumentPath
        self.sharedDocumentName = sharedDocumentName
    }
 
    var body: some View {
        NavigationStack {
            Form {
                Section("Document Details") {
                    TextField("Document name", text: $name)
                    TextField("Document type", text: $documentType)
                }
 
                Section("Health Requirement") {
                    Picker(
                        "Requirement",
                        selection: $selectedRequirementID
                    ) {
                        Text("Choose a requirement")
                            .tag(nil as UUID?)
 
                        ForEach(requirements) { requirement in
                            Text(requirement.title)
                                .tag(requirement.id as UUID?)
                        }
                    }
                }
 
                Section("Document") {
                    if sharedDocumentPath != nil {
                        Label(
                            "Shared document ready",
                            systemImage: "checkmark.circle"
                        )
                    } else {
                        Button("Scan Document") {
                            showingScanner = true
                        }
 
                        if scannedPDFData != nil {
                            Label(
                                "Document scanned",
                                systemImage: "checkmark.circle"
                            )
                        }
                    }
                }
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
 
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDocument()
                    }
                }
            }
            .onAppear {
                loadRequirements()
 
                if let sharedDocumentName {
                    name = sharedDocumentName
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView { pdfData in
                    scannedPDFData = pdfData
                }
            }
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
 
    private func loadRequirements() {
        do {
            requirements = try requirementRepository.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
 
    private func saveDocument() {
        guard let requirementID = selectedRequirementID else {
            errorMessage = "Choose a health requirement before saving this document."
            return
        }
        do {
            let filePath: String
            if let sharedDocumentPath {
                filePath = sharedDocumentPath
            } else {
                guard let pdfData = scannedPDFData else {
                    errorMessage = "Scan a document before saving."
                    return
                }
                filePath = try DocumentStorageService().savePDF(pdfData)
            }
 
            let document = Document(
                id: UUID(),
                name: name,
                filePath: filePath,
                dateAdded: Date(),
                documentType: documentType,
                healthRequirementID: requirementID
            )
            if viewModel.addDocument(document) {
                if sharedDocumentPath != nil {
                    clearSharedDocument()
                }
                dismiss()
            } else {
                errorMessage = viewModel.errorMessage
            }
 
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func clearSharedDocument() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.Assignment3.HealthPath")
        sharedDefaults?.removeObject(
            forKey: "sharedDocumentPath"
        )
        sharedDefaults?.removeObject(
            forKey: "sharedDocumentName"
        )
    }
}
