//
//  HealthPathTests.swift
//  HealthPathTests
//
//  Created by emily zhang on 26/9/2026.
//

import Testing
import Foundation
@testable import HealthPath

struct HealthPathTests {
    
    /// An applicant adds a valid health requirement to their existing health case.
    /// The requirement has a title, a valid due date and belongs to the health case loaded from SampleHealthCase.json.
    @Test func addRequirement_withValidDetails_savesIt() throws {
        //Create the Local repositories using the sample JSON data included in the app.
        let requirementRepository = LocalHealthRequirementRepository()
        let caseRepository = LocalHealthCaseRepository()
        
        // Record the number of requirements exist before adding a new one.
        let totalBeforeAdd = requirementRepository.requirements.count
        
        // Use the applicant's existing health case from SampleHealthCase.json.
        let healthCase = try #require(try caseRepository.fetch())
        
        // Create a new health requirement belonging to the existing health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Video telehealth (VDOT)",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: healthCase.id
        )
        
        // Create the use case with the local repositories.
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        
        // Execute and expect a new requirement to be saved.
        try useCase.execute(requirement)
        #expect(requirementRepository.requirements.count > totalBeforeAdd)
    }
    
    /// An applicant leaves the title empty, so they are asked to enter one.
    /// An empty file should produce the emptyTitle domain error.
    @Test func addRequirement_withEmptyTitle_throwsEmptyTitle() throws {
        //Create the Local repositories using the sample JSON data included in the app.
        let requirementRepository = LocalHealthRequirementRepository()
        let caseRepository = LocalHealthCaseRepository()
        
        // Use the applicant's existing health case from SampleHealthCase.json.
        let healthCase = try #require(try caseRepository.fetch())
        
        // Create a requirement with an empty title.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: healthCase.id
        )
        // Create the use case.
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        
        // Expect an emptyTitle error when executing.
        #expect(throws: AddHealthRequirementError.emptyTitle) {
            try useCase.execute(requirement)
        }
    }
    
    /// An applicant enters an invalid date, so they are asked to enter a valid date.
    /// A due date more than five years from now should produce the invalidDueDate domain error.
    @Test func addRequirement_withInvalidDueDate_throwsInvalidDueDate() throws {
        // Create the local repositories using the sample JSON data included in the app.
        let requirementRepository = LocalHealthRequirementRepository()
        let caseRepository = LocalHealthCaseRepository()
        
        // Use the applicant's existing health case from SampleHealthCase.json.
        let healthCase = try #require(try caseRepository.fetch())
        let now = Date()
        
        // Create a date six years from now, which breakes the business rule.
        let invalidDate = try #require(
            Calendar.current.date(byAdding: .year, value: 6, to: now)
        )
        
        // Create a requirement with the invalid due date.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Video telehealth (VDOT)",
            descriptionText: "",
            dueDate: invalidDate,
            status: .actionRequired,
            healthCaseID: healthCase.id
        )
        
        //Create the use case.
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        
        // Expect an invalidDueDate error when executing.
        #expect(throws: AddHealthRequirementError.invalidDueDate) {
            try useCase.execute(requirement, now: now)
        }
    }
    
    /// An applicant can mark an outstanding health requirement as completed.
    /// The Chest X-ray requirement in SampleRequirements.json starts as actionRequired.
    @Test func completeRequirement_thatNeedsAction_marksItComplete() throws {
        // Load the sample health requirement.
        let repository = LocalHealthRequirementRepository()
        
        // Use the existing Chest X-ray from SampleRequirements.json.
        let requirementID = UUID(uuidString:"B1000000-0000-0000-0000-000000000001")!
        
        // Create the use case.
        let useCase = CompleteHealthRequirementUseCase(repository: repository)
        
        // Execute and expect requirement to be marked as completed with a completion date.
        try useCase.execute(id: requirementID)
        let requirement = try repository.fetchRequirement(withID: requirementID)
        #expect(requirement?.status == .completed)
        #expect(requirement?.completedDate != nil)
    }
    
    /// An applicant whose health requirement is already completed cannot be completed again.
    /// The Specalist Appointment in SampleRequirements.json is already completed.
    @Test func completeRequirement_thatIsAlreadyCompleted_throwsAlreadyCompleted() {
        let repository = LocalHealthRequirementRepository()
        
        // Use the existing completed Specalist Appointment requirement.
        let requirementID = UUID(uuidString: "B1000000-0000-0000-0000-000000000003")!
        
        // Create the use case.
        let useCase = CompleteHealthRequirementUseCase(repository: repository)
        
        // Expect an alreadyCompleted error when executing.
        #expect(throws: CompleteHealthRequirementError.alreadyCompleted) {
            try useCase.execute(id: requirementID)
        }
    }
    
    /// An applicant 's future health appointment can be recorded for an existing health requirement.
    /// The new appointment belongs to the Chest X-ray requirement in SampleRequirements.json.
    @Test func scheduleAppointment_withValidDetails_savesIt() throws {
        let appointmentRepository = LocalAppointmentRepository()
        let requirementRepository = LocalHealthRequirementRepository()
        
        // Record how many appointments exists before adding a new one.
        let totalBeforeAdd = appointmentRepository.appointments.count
        
        // Add 24 hours (86400 seconds) to the current date to get tomorrow.
        let tomorrow = Date().addingTimeInterval(86400)
        
        // Use the existing Chest X-ray requirement.
        let requirementID = UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!
        
        // Create a new appointment for tomorrow .
        let appointment = Appointment(
            id: UUID(),
            title: "Chest X-ray follow-up",
            date: tomorrow,
            location: "Radiology Department",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: requirementID
        )
        
        // Create the use case.
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        
        // Execute and expect one more poointment should now be stored.
        try useCase.execute(appointment)
        #expect(appointmentRepository.appointments.count > totalBeforeAdd)
    }
    
    /// An applicant's appointment cannot be recorded with a date and time in the past.
    /// A past appointment should produce the appointmentInPast domain error.
    @Test func scheduleAppointment_withPastDate_throwsAppointmentInPast() {
        // Load
        let appointmentRepository = LocalAppointmentRepository()
        let requirementRepository = LocalHealthRequirementRepository()
        
        // Use the existing Chest X-ray requirement.
        let requirementID = UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!
        
        // Subtract 24 hours (86400 seconds) from the current date to get tomorrow.
        let yesterday = Date().addingTimeInterval(-86400)
        
        // Create an appointment for yesterday.
        let appointment = Appointment(
            id: UUID(),
            title: "Chest X-ray follow-up",
            date: yesterday,
            location: "Radiology Department",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: requirementID
        )
        
        // Create the use case.
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        
        // Expect an appointmentInPast error when executing.
        #expect(throws: ScheduleHealthAppointmentError.appointmentInPast){
            try useCase.execute(appointment)
        }
    }
    
    ///An applicant cannot add a new appointment to a completed health requirement.
    @Test func scheduleAppointment_forCompletedRequirement_throwsRequirementCompleted() throws {
        let appointmentRepository = LocalAppointmentRepository()
        let requirementRepository = LocalHealthRequirementRepository()
        
        // Use an existing completed requirement from the sample data
        let completedRequirement = try #require(
            try requirementRepository.fetchAll().first {
            $0.status == .completed
            }
        )
        
        // Use a fixed current time and create an appointment one hour later.
        let now = Date()
        
        // Add 1 hour to the current time.
        let oneHourFromNow = now.addingTimeInterval(3600)
        
        // Create an appointment 1 hour from now.
        let appointment = Appointment(
            id: UUID(),
            title: "Follow-up appointment",
            date: oneHourFromNow,
            location: "St George Chest Clinic",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: completedRequirement.id
        )
        // Create the use case.
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        // Expect a requirementCompleted error when executing.
        #expect(throws: ScheduleHealthAppointmentError.requirementCompleted) {
            try useCase.execute(appointment, now: now)
        }
    }
    
    /// An applicant's health document can be added to an existing health requirement.
    /// The new document belongs to the Chest X-ray requirement in SampleRequirements.json
    @Test func addDocument_withValidDetails_savesIt() throws {
        let documentRepository = LocalDocumentRepository()
        let requirementRepository = LocalHealthRequirementRepository()
        
        // Record how many documents exist before adding a new one
        let totalBeforeAdd = documentRepository.documents.count
        
        // Use the existing Chest X-ray requirement.
        let requirementID = UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!
        
        // Create a new document with a saved file path.
        let document = Document(
            id: UUID(),
            name: "Chest X-ray result",
            filePath: "chest-xray-result.pdf",
            dateAdded: Date(),
            documentType: "Result",
            healthRequirementID: requirementID
        )
        
        // Create the use case.
        let useCase = AddDocumentUseCase(
            documentRepository: documentRepository,
            requirementRepository: requirementRepository
        )
        
        // Execute and expect one more document should now be stored.
        try useCase.execute(document)
        #expect(documentRepository.documents.count > totalBeforeAdd)
    }
    
    /// The applicant cannot add a health document without a saved file path.
    /// An empty file path should produce the emptyFile domain error.
    @Test func addDocument_withEmptyFilePath_throwsEmptyFile() {
        let documentRepository = LocalDocumentRepository()
        let requirementRepository = LocalHealthRequirementRepository()
        
        // Use the existing Chest X-ray requirement.
        let requirementID = UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!
        
        // Create a document without a file path.
        let document = Document(
            id: UUID(),
            name: "Chest X-ray result",
            filePath: "",
            dateAdded: Date(),
            documentType: "Result",
            healthRequirementID: requirementID
        )
        
        // Create the use case.
        let useCase = AddDocumentUseCase(
            documentRepository: documentRepository,
            requirementRepository: requirementRepository
        )
        
        // Expect an emptyFile error when executing.
        #expect(throws: AddDocumentError.emptyFile){
            try useCase.execute(document)
        }
    }
    
    /// When the applicant has a Chest X-ray requirement, it returns the appointment for that requirement.
    /// SampleAppointments.json contains one appointment linked to the Chest X-ray requirement.
    @Test func fetchAppointments_forRequirement_returnsAppointment() throws {
        let repository = LocalAppointmentRepository()
        
        // Use the existing Chest X-ray requirement.
        let requirementID = UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!
        
        // Execute and expect one matching appointment.
        let appointments = try repository.fetchAppointments(for: requirementID)
        #expect(appointments.count == 1)
    }
}
