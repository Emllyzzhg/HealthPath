//
//  HealthCase.swift
//  HealthPath
//
//  Created by emily zhang on 28/9/2026.
//

import Foundation

/// The applicant's overall health-requirement process for their visa.
///
/// A health case is the container for everything the applicant needs to do,
/// such as their medical examination, chest X-ray and specialist follow-up.
/// Each health requirement belongs to the case, and each requirement keeps its
/// own appointments and documents.
///
/// HealthPath creates one case for the applicant when they get started. It is the
/// applicant's own record. It does not connect to Home Affairs or eMedical.
///
/// Business rules
/// 1. Every health requirement must belong to a health case.
///
/// This rule is checked when the applicant adds a requirement. See AddHealthRequirementUseCase.

struct HealthCase: Identifiable {
    let id: UUID
    let createdDate:Date
}
