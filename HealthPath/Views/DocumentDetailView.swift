//
//  DocumentDetailView.swift
//  HealthPath
//
//  Created by emily zhang on 4/10/2026.
//

import SwiftUI
import PDFKit
 
struct DocumentDetailView: View {
    let document: Document
 
    var body: some View {
        PDFViewer(filePath: document.filePath)
            .navigationTitle(document.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}
 
private struct PDFViewer: UIViewRepresentable {
    let filePath: String
 
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
 
        pdfView.autoScales = true
        pdfView.document = PDFDocument(
            url: URL(fileURLWithPath: filePath)
        )
 
        return pdfView
    }
 
    func updateUIView(
        _ pdfView: PDFView,
        context: Context
    ) {
    }
}
