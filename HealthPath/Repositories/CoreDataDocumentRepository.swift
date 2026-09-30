//
//  CoreDataDocumentRepository.swift
//  HealthPath
//
//  Created by emily zhang on 29/9/2026.
//

import CoreData
/// Keeps the applicant's health documents in the app's Core Data store.
/// This is the only place that talks to the database about documents.
/// Use cases work through DocumentRepository, so the business rules never depend on Core Data.
/// The database keeps each document's details and the name of its saved file.
/// The file itself is stored separately on the device.
final class CoreDataDocumentRepository: DocumentRepository {
 
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    /// Returns the documents the applicant has added, newest first.
    /// A document that is not linked to a health requirement is left out.
    func fetchAll() throws -> [Document] {
        let request = DocumentEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        let entities = try context.fetch(request)

        var documents: [Document] = []
        for entity in entities {
            guard let id = entity.id,
                  let dateAdded = entity.dateAdded,
                  let requirementID = entity.healthRequirement?.id else {
                continue
            }
            let document = Document(
                id: id,
                name: entity.name ?? "",
                filePath: entity.filePath ?? "",
                dateAdded: dateAdded,
                documentType: entity.documentType ?? "",
                healthRequirementID: requirementID
            )
            documents.append(document)
        }
        return documents
    }
 
    /// Returns the documents kept with one health requirement, newest first.
    /// The requirement, such as "Chest X-ray".
    func fetchDocuments(for requirementID: UUID) throws -> [Document] {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "healthRequirement.id == %@",
            requirementID as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        let entities = try context.fetch(request)

        var documents: [Document] = []
        for entity in entities {
            guard let id = entity.id,
                  let dateAdded = entity.dateAdded else {
                continue
            }
            let document = Document(
                id: id,
                name: entity.name ?? "",
                filePath: entity.filePath ?? "",
                dateAdded: dateAdded,
                documentType: entity.documentType ?? "",
                healthRequirementID: requirementID
            )
            documents.append(document)
        }
        return documents
    }
    
    /// Saves a newly added document and links it to its health requirement.
    /// Throws DocumentRepositoryError/requirementNotFound if the health requirement does not exist.
    func add(_ document: Document) throws {
        let request = HealthRequirementEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            document.healthRequirementID as CVarArg
        )
        guard let requirementEntity = try context.fetch(request).first else {
            throw DocumentRepositoryError.requirementNotFound
        }
        
        let entity = DocumentEntity(context: context)
        entity.id = document.id
        entity.name = document.name
        entity.filePath = document.filePath
        entity.dateAdded = document.dateAdded
        entity.documentType = document.documentType
        entity.healthRequirement = requirementEntity
        
        try context.save()
    }
 
    /// Saves changes to an existing document, for example a new name.
    /// A document stays with the requirement it was added to, and its date added does not change.
    /// Throws DocumentRepositoryError/documentNotFound if the document is no longer stored.
    func update(_ document: Document) throws {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            document.id as CVarArg
        )
        guard let entity = try context.fetch(request).first else {
            throw DocumentRepositoryError.documentNotFound
        }
        
        entity.name = document.name
        entity.filePath = document.filePath
        entity.documentType = document.documentType
        try context.save()
    }
 
    /// Removes a document the applicant no longer wants to keep.
    /// The saved file is not removed here. If the document can't be found, nothing changes.
    func delete(_ document: Document) throws {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@",
            document.id as CVarArg
        )
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
        }
    }
}
