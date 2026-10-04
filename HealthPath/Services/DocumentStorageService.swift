//
//  DocumentStorageService.swift
//  HealthPath
//
//  Created by emily zhang on 3/10/2026.
//

import Foundation

/// Saves scanned PDF files on the app's Local Documents directory on the device  and returns the path to the saved file.
/// The PDF itself is stored as a file, while its file path is stored in SwiftData
struct DocumentStorageService {
    enum Error: LocalizedError {
        case emptyDocument
        case unableToSaveDocument
        
        var errorDescription: String? {
            switch self {
            case .emptyDocument:
                return "This document is empty. Scan the document and try again."
            case .unableToSaveDocument:
                return "We couldn't save this document on your device. Please try again."
            }
        }
    }
    
    func savePDF(_ data: Data) throws -> String {
        guard !data.isEmpty else {
            throw Error.emptyDocument
        }
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        let fileName = UUID().uuidString + ".pdf"
        
        let fileURL = documentsDirectory
            .appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            throw Error.unableToSaveDocument
        }
    }
}
