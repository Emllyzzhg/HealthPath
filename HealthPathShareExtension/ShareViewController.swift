//
//  ShareViewController.swift
//  HealthPathShareExtension
//
//  Created by emily zhang on 4/10/2026.
//

import UIKit
import Social
import UniformTypeIdentifiers
 
class ShareViewController: SLComposeServiceViewController {
 
    private let appGroup = "group.com.Assignment3.HealthPath"
 
    override func isContentValid() -> Bool {
        return true
    }
 
    override func didSelectPost() {
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachment = extensionItem.attachments?.first
        else {
            extensionContext?.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
            return
        }
 
        guard attachment.hasItemConformingToTypeIdentifier(
            UTType.pdf.identifier
        ) else {
            extensionContext?.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
            return
        }
 
        attachment.loadFileRepresentation(
            forTypeIdentifier: UTType.pdf.identifier
        ) { fileURL, error in
            guard
                error == nil,
                let fileURL
            else {
                print("HealthPath Share: Could not load PDF")
                print("Error:", error?.localizedDescription ?? "No error")
                self.extensionContext?.completeRequest(
                    returningItems: [],
                    completionHandler: nil
                )
                return
            }
            print("HealthPath Share: Received PDF")
            self.saveSharedDocument(from: fileURL)
        }
    }
 
    private func saveSharedDocument(from sourceURL: URL) {
        print("HealthPath Share: Received PDF:", sourceURL)
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup
        ) else {
            extensionContext?.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
            return
        }
 
        let sharedDocumentsURL = containerURL
            .appendingPathComponent("SharedDocuments")
 
        do {
            try FileManager.default.createDirectory(
                at: sharedDocumentsURL,
                withIntermediateDirectories: true
            )
 
            let destinationURL = sharedDocumentsURL
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("pdf")
 
            try FileManager.default.copyItem(
                at: sourceURL,
                to: destinationURL
            )
 
            let sharedDefaults = UserDefaults(
                suiteName: appGroup
            )
 
            sharedDefaults?.set(
                destinationURL.path,
                forKey: "sharedDocumentPath"
            )
 
            sharedDefaults?.set(
                sourceURL.lastPathComponent,
                forKey: "sharedDocumentName"
            )
            print("HealthPath Share: PDF saved to App Group")
            print("Path:", destinationURL.path)
 
            extensionContext?.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
 
        } catch {
            extensionContext?.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
        }
    }
 
    override func configurationItems() -> [Any]! {
        return []
    }
}
