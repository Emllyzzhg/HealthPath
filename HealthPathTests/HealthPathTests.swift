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

    /// An applicant adds "Chest X-ray" to their existing health case, and it is saved.
    @Test func addRequirement_withTitleAndExistingHealthCase_savesIt() throws {
        let requirementRepository = MockHealthRequirementRepository()
        let caseRepository = MockHealthCaseRepository()
        let healthCaseID = UUID()
        // Tell the fake case repository that a health case with that ID exists
        caseRepository.healthCase = HealthCase(id: healthCaseID, createdDate: Date())
        // Create the use case using those mocks
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        // Create a requirement associated with that health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: healthCaseID
        )
        // Execute and expect requirement to be saved
        try useCase.execute(requirement)
        #expect(requirementRepository.requirements.count == 1)
    }

    /// An applicant leaves the title empty, so they are asked to enter one.
    @Test func addRequirement_withEmptyTitle_throwsEmptyTitle() {
        let requirementRepository = MockHealthRequirementRepository()
        let caseRepository = MockHealthCaseRepository()
        let healthCaseID = UUID()
        // Tell the fake case repository that a health case with that ID exists
        caseRepository.healthCase = HealthCase(id: healthCaseID, createdDate: Date())
        // Create the use case using those mocks
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        // Create a requirement associated with that health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: healthCaseID
        )
        // Expect an emptyTitle error when executing
        #expect(throws: AddHealthRequirementError.emptyTitle) {
            try useCase.execute(requirement)
        }
    }
    
    /// An applicant types only spaces as the title, which counts as empty.
    @Test func addRequirement_withOnlySpacesInTitle_throwsEmptyTitle() {
        let requirementRepository = MockHealthRequirementRepository()
        let caseRepository = MockHealthCaseRepository()
        let healthCaseID = UUID()
        // Tell the fake case repository that a health case with that ID exists
        caseRepository.healthCase = HealthCase(id: healthCaseID, createdDate: Date())
        // Create the use case using those mocks
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        // Create a requirement associated with that health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "     ",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: healthCaseID
        )
        // Expect an emptyTitle error when executing
        #expect(throws: AddHealthRequirementError.emptyTitle) {
            try useCase.execute(requirement)
        }
    }
    
    /// An applicant records a requirement that was due yesterday. This is allowed, because it may already be late or done.
    @Test func addRequirement_withDueDateYesterday_savesIt() throws {
        let requirementRepository = MockHealthRequirementRepository()
        let caseRepository = MockHealthCaseRepository()
        let healthCaseID = UUID()
        // Tell the fake case repository that a health case with that ID exists
        caseRepository.healthCase = HealthCase(id: healthCaseID, createdDate: Date())
        // Create the use case using those mocks
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        // Create a date from yesterday
        let yesterday = Date().addingTimeInterval(-60 * 60 * 24)
        // Create a requirement associated with that health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: yesterday,
            status: .actionRequired,
            healthCaseID: healthCaseID
        )
        // Execute and expect requirement to be saved
        try useCase.execute(requirement)
        #expect(requirementRepository.requirements.count == 1)
    }
    
    /// An applicant enters a due date six years away, which is probably a typo, so they are asked to check the date.
    @Test func addRequirement_withDueDateSixYearsAway_throwsInvalidDueDate() {
        let requirementRepository = MockHealthRequirementRepository()
        let caseRepository = MockHealthCaseRepository()
        let healthCaseID = UUID()
        // Tell the fake case repository that a health case with that ID exists
        caseRepository.healthCase = HealthCase(id: healthCaseID, createdDate: Date())
        // Create the use case using those mocks
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        // Create a date 6 years from now
        let sixYearsAway = Date().addingTimeInterval(60 * 60 * 24 * 365 * 6)
        // Create a requirement associated with that health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: sixYearsAway,
            status: .actionRequired,
            healthCaseID: healthCaseID
        )
        // Expect an invalidDueDate error when executing
        #expect(throws: AddHealthRequirementError.invalidDueDate) {
            try useCase.execute(requirement)
        }
    }
    
    /// An applicant has not started a health case, so the requirement cannot be added.
    @Test func addRequirement_whenNoHealthCaseExists_throwsHealthCaseNotFound() {
        let requirementRepository = MockHealthRequirementRepository()
        let caseRepository = MockHealthCaseRepository()
        // Create the use case using those mocks
        let useCase = AddHealthRequirementUseCase(
            requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        // Create a requirement associated with that health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: UUID()
        )
        // Expect an healthCaseNotFound error when executing
        #expect(throws: AddHealthRequirementError.healthCaseNotFound) {
            try useCase.execute(requirement)
        }
    }
    
    /// An applicant types spaces around the title, and the saved title has them removed.
    @Test func addRequirement_withSpacesAroundTitle_savesTrimmedTitle() throws {
        let requirementRepository = MockHealthRequirementRepository()
        let caseRepository = MockHealthCaseRepository()
        let healthCaseID = UUID()
        // Tell the fake case repository that a health case with that ID exists
        caseRepository.healthCase = HealthCase(id: healthCaseID, createdDate: Date())
        // Create the use case using those mocks
        let useCase = AddHealthRequirementUseCase(
               requirementRepository: requirementRepository,
            caseRepository: caseRepository
        )
        // Create a requirement associated with that health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "  Chest X-ray  ",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: healthCaseID
        )
        // Execute and expect the title to be trimmed when saved
        try useCase.execute(requirement)
        #expect(requirementRepository.requirements[0].title == "Chest X-ray")
        }
    
    /// Completing a requirement records the date it was completed.
    @Test func completeRequirement_thatNeedsAction_recordsTheCompletedDate() throws {
        let repository = MockHealthRequirementRepository()
        // Create a requirement associated with a health case.
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository.
        repository.requirements = [requirement]
        // Create the use case with the repository.
        let useCase = CompleteHealthRequirementUseCase(repository: repository)
        // Execute and expect the completion date to be recorded.
        try useCase.execute(id: requirement.id)
        #expect(repository.requirements[0].completedDate != nil)
    }
    
    /// An applicant records a chest X-ray appointment for tomorrow, and it is saved.
    @Test func scheduleAppointment_withTitleFutureDateAndExistingRequirement_savesIt() throws {
        let appointmentRepository = MockAppointmentRepository()
        let requirementRepository = MockHealthRequirementRepository()
        // Create an existing health requirement for the appointment
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository
        requirementRepository.requirements = [requirement]
        // Create the use case using the mock repositories
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        // Create an appointment for tomorrow
        let tomorrow = Date().addingTimeInterval(60 * 60 * 24)
        let appointment = Appointment(
            id: UUID(),
            title: "Chest X-ray",
            date: tomorrow,
            location: "Radiology St George Hospital",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: requirement.id
        )
        // Execute and expect appointment to be saved
        try useCase.execute(appointment)
        #expect(appointmentRepository.appointments.count == 1)
        }
    
    /// An applicant leaves the appointment title empty, so they are asked to enter one.
    @Test func scheduleAppointment_withEmptyTitle_throwsEmptyTitle() {
        let appointmentRepository = MockAppointmentRepository()
        let requirementRepository = MockHealthRequirementRepository()
        // Create an existing health requirement for the appointment
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository
        requirementRepository.requirements = [requirement]
        // Create the use case using the mock repositories
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        // Create an appointment for tomorrow but with no title
        let tomorrow = Date().addingTimeInterval(60 * 60 * 24)
        let appointment = Appointment(
            id: UUID(),
            title: "",
            date: tomorrow,
            location: "",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: requirement.id
        )
        // Expect an emptyTitle error when executing
        #expect(throws: ScheduleHealthAppointmentError.emptyTitle) {
            try useCase.execute(appointment)
        }
    }
    
    /// An applicant chooses a date that was yesterday, so they are asked to choose another date.
    @Test func scheduleAppointment_withDateYesterday_throwsAppointmentInPast() {
        let appointmentRepository = MockAppointmentRepository()
        let requirementRepository = MockHealthRequirementRepository()
        // Create an existing health requirement for the appointment
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository
        requirementRepository.requirements = [requirement]
        // Create the use case using the mock repositories
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        // Create an appointment for yesterday
        let yesterday = Date().addingTimeInterval(-60 * 60 * 24)
        let appointment = Appointment(
            id: UUID(),
            title: "Chest X-ray",
            date: yesterday,
            location: "",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: requirement.id
        )
        // Expect an appointmentInPast error when executing
        #expect(throws: ScheduleHealthAppointmentError.appointmentInPast) {
            try useCase.execute(appointment)
        }
    }
    
    /// An appointment at the start of today is still allowed, because it is today.
    @Test func scheduleAppointment_atStartOfToday_savesIt() throws {
        let appointmentRepository = MockAppointmentRepository()
        let requirementRepository = MockHealthRequirementRepository()
        // Create an existing health requirement for the appointment
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository
        requirementRepository.requirements = [requirement]
        // Create the use case using the mock repositories
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        // Create an appointment for today
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let appointment = Appointment(
            id: UUID(),
            title: "Chest X-ray",
            date: startOfToday,
            location: "",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: requirement.id
        )
        // Execute and expect appointment to be saved
        try useCase.execute(appointment)
        #expect(appointmentRepository.appointments.count == 1)
    }
    
    /// An appointment is linked to a requirement that no longer exists, so it is not saved.
    @Test func scheduleAppointment_forRequirementThatDoesNotExist_throwsRequirementNotFound() {
        let appointmentRepository = MockAppointmentRepository()
        let requirementRepository = MockHealthRequirementRepository()
        // Create the use case using the mock repositories
        let useCase = ScheduleHealthAppointmentUseCase(
            appointmentRepository: appointmentRepository,
            requirementRepository: requirementRepository
        )
        // Create an appointment for tomorrow
        let tomorrow = Date().addingTimeInterval(60 * 60 * 24)
        let appointment = Appointment(
            id: UUID(),
            title: "Chest X-ray",
            date: tomorrow,
            location: "",
            descriptionText: "",
            isCompleted: false,
            healthRequirementID: UUID()
        )
        // Expect a requirementNotFound error when executing
        #expect(throws: ScheduleHealthAppointmentError.requirementNotFound) {
            try useCase.execute(appointment)
        }
    }
    
    /// An applicant marks a requirement that needs action as completed, and its status changes.
    @Test func completeRequirement_thatNeedsAction_marksItCompleted() throws {
        let repository = MockHealthRequirementRepository()
        // Create a health requirement
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .actionRequired,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository
        repository.requirements = [requirement]
        // Create the use case using the mock repository
        let useCase = CompleteHealthRequirementUseCase(repository: repository)
        // Execute and expect the requirement to be completed
        try useCase.execute(id: requirement.id)
        #expect(repository.requirements[0].status == .completed)
    }
    
    /// An applicant tries to complete a requirement that is already completed, so they are told it is already done.
    @Test func completeRequirement_thatIsAlreadyCompleted_throwsAlreadyCompleted() {
        let repository = MockHealthRequirementRepository()
        // Create a health requirement
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: Date(),
            status: .completed,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository
        repository.requirements = [requirement]
        // Create the use case using the mock repository
        let useCase = CompleteHealthRequirementUseCase(repository: repository)
        // Expect an alreadyCompleted error when executing
        #expect(throws: CompleteHealthRequirementError.alreadyCompleted) {
            try useCase.execute(id: requirement.id)
        }
    }
    
    /// An applicant tries to complete a requirement that no longer exists.
    @Test func completeRequirement_thatDoesNotExist_throwsRequirementNotFound() {
        let repository = MockHealthRequirementRepository()
        // Create the use case using the mock repository
        let useCase = CompleteHealthRequirementUseCase(repository: repository)
        // Expect a requirementNotFound error when executing
        #expect(throws: CompleteHealthRequirementError.requirementNotFound) {
            try useCase.execute(id: UUID())
        }
    }
    
    /// A late requirement can still be completed, and once completed it is no longer overdue.
    @Test func completeRequirement_thatIsOverdue_marksItCompletedAndNoLongerOverdue() throws {
        let repository = MockHealthRequirementRepository()
        // Create a requirement due yesterday
        let yesterday = Date().addingTimeInterval(-60 * 60 * 24)
        // Create an overdue health requirement
        let requirement = HealthRequirement(
            id: UUID(),
            title: "Chest X-ray",
            descriptionText: "",
            dueDate: yesterday,
            status: .upcoming,
            healthCaseID: UUID()
        )
        // Add the requirement to the repository
        repository.requirements = [requirement]
        // Create the use case using the mock repository
        let useCase = CompleteHealthRequirementUseCase(repository: repository)
        // Execute and expect the requirement to no longer be overdue
        try useCase.execute(id: requirement.id)
        #expect(repository.requirements[0].isOverdue() == false)
    }
}
