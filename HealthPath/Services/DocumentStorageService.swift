//
//  DocumentStorageService.swift
//  HealthPath
//
//  Created by emily zhang on 3/10/2026.
//

import Foundation

/// Saves document files on the device and returns the path to the saved file.
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
    
    func savePDF(_ data: Data, fileName: String) throws -> String {
        guard !data.isEmpty else {
            throw Error.emptyDocument
        }
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        let fileURL = documentsDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension("pdf")
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            throw Error.unableToSaveDocument
        }
    }
}
 
