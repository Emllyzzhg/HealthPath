//
//  DocumentScannerView.swift
//  HealthPath
//
//  Created by emily zhang on 3/10/2026.
//

import SwiftUI
import VisionKit
import PDFKit

/// Uses Apple's document scanner so that the applicant can scan health paperwork.
/// The scanner can capture one or more pages.
/// When the applicant finishes scanning, the pages are combines into a single PDF and returned as data.
/// The scanner does not save the PDF itself.
/// The scanned data can be passed to DocumentStorageServce to save the file and obtain its file path.
struct DocumentScannerView: UIViewControllerRepresentable {
    /// Handles the PDF data after a successful scan.
    let onScanComplete: (Data) -> Void
    
    /// Creates and configures the document scanner.
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController{
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    /// Updates the document scanner when the SwiftUI view changes.
    func updateUIViewController(
        _ uiViewController: VNDocumentCameraViewController,
        context: Context
    ) {
    }
    
    /// Creates the coordinator for handling scan results.
    func makeCoordinator() -> Coordinator {
        Coordinator(onScanComplete: onScanComplete)
    }
    
    /// Handles the results when a document scan is completed.
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onScanComplete: (Data) -> Void
        
        /// Creates a coordinator with a handler for the completed PDF.
        init(onScanComplete: @escaping (Data) -> Void) {
            self.onScanComplete = onScanComplete
        }
        
        /// Converts the scanned pages into a PDF and returns the PDF data.
        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            let pdfDocument = PDFDocument()
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let page = PDFPage(image: image) {
                    pdfDocument.insert(
                        page,
                        at: pdfDocument.pageCount
                    )
                }
            }
            guard let pdfData = pdfDocument.dataRepresentation(),
                  !pdfData.isEmpty else {
                controller.dismiss(animated: true)
                return
            }
            controller.dismiss(animated: true) {
                self.onScanComplete(pdfData)
            }
        }
        
        /// Closes the scanner when the user cancels the scan.
        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            controller.dismiss(animated: true)
        }
        
        /// Closes the scanner when the scan fails.
        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            controller.dismiss(animated: true)
        }
    }
}
