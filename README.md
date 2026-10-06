# HealthPath    
 
## Project Overview    
 
HealthPath is an iOS application designed to help patients organise health requirements, related appointments and documents in one place.    
 
 The application allows users to:    
 - Create and manage health requirements    
 - Track requirement due dates and completion status    
 - Schedule appointments related to a health requirement    
 - Store and view related health documents    
 - Scan physical documents using VisionKit    
 - View the next upcoming appointment or health requirement through the WidgetKit extension    
 - Share PDF documents into HealthPath through the iOS share sheet    
 
HealthPath was developed as a university assessment project and does not claim regulatory compliance. A production version would require further assessment of privacy, security, access control and applicable regulatory requirements.    
 
## Domain Context    
 
HealthPath focuses on patients completing migration-related tuberculosis (TB) health follow up through a chest clinic, particularly where multiple health requirements, appointments and documents may need to be managed over time.    
 
The application acts as a personal organisational tool. It does not diagnose medical conditions, determine visa eligibility or status, or replace official services such as the Department of Home Affairs, eMedical, Bupa Medical Visa Services or healthcare providers.    
 
The core domain relationship is:    
 
`HealthCase` → `HealthRequirement` → `Appointment` / `Document`  
 
A health case can have many health requirements. A health requirement provides the context for its related appointments and documents.    
 
## Architecture Summary    
 
HealthPath follows an MVVM-based architecture with separate layers for user interface, business logic and persistence:    
 
SwiftUI Views    
 → ViewModels    
 → Use Cases    
 → Repository Protocols    
 → SwiftData Repositories    
 → SwiftData    
 
The main use cases are:    
 - `AddHealthRequirementUseCase`    
 - `CompleteHealthRequirementUseCase`    
 - `ScheduleHealthAppointmentUseCase`    
 - `AddDocumentUseCase`    
 
Repository protocols separate the application's business logic from SwiftData persistence and allow local repositories to be used for isolated testing.    
 
## Chosen Extensions and iOS Features  
 
### WidgetKit Extension    
 
The WidgetKit extension provides a quick view of the next upcoming appointment or health requirement that currently needs the user's attention without requiring navigation through the main application. It prioritises the next future appointment and when there is no upcoming appointment, displays the next health requirement and its due date.   
 
### Share Extension    
 
The Share Extension allows a PDF opened in another application to be shared into HealthPath using the iOS share sheet. The PDF is copied into the shared App Group container so it can be accessed by the main application and added to the patient’s documents.    
 
### VisionKit  Document Scanning  
 
VisionKit complements document sharing by allowing a physical health document to be scanned directly into HealthPath and then saved to the appropriate health requirement.  
 
## Database Choice    
 
HealthPath uses SwiftData for local persistent storage. This allows health requirements, appointments and document records to remain available between application launches and accessible offline. The information is intended for the individual patient, and HealthPath does not currently require cloud storage or synchronisation between different users. 
 
The SwiftData schema contains:    
 - `HealthCaseModel`    
- `HealthRequirementModel`    
- `AppointmentModel`    
- `DocumentModel` 

A `HealthCaseModel` contains related health requirements, while a `HealthRequirementModel` can have related appointments and documents.    
 
## App Group Identifier    
 
The main HealthPath application, WidgetKit extension and Share Extension use the following App Group:    
 
`group.com.Assignment3.HealthPath`    
 
The App Group provides shared storage that allows the main HealthPath application and its extensions to access shared information.    
 
## Setup Instructions   
 
1. Clone the HealthPath repository and open the project in Xcode.   
2. Select the HealthPath application target.  
3. Confirm that the required signing team is selected under **Signing & Capabilities**.    
4. Confirm that the App Group capability contains: `group.com.Assignment3.HealthPath`    
5. Confirm that the same App Group is enabled for the WidgetKit and Share Extension targets.    
6. Ensure the deployment target is iOS 26.0 or later.    
7. Select an iOS Simulator or compatible physical iPhone.    
8. Build and run the `HealthPath` scheme.    
9. To test the widget, add the HealthPath widget from the iOS Home Screen.    
10. To test the Share Extension, open a PDF in another application, tap the iOS share button and choose HealthPath. In the share sheet, tap **Post**, then open HealthPath and select the **Documents** tab.  
11. When using VisionKit to scan a physical document, allow camera access when prompted.  
 
## Testing     

HealthPath uses Swift Testing for unit testing. The test suite covers the main business rules, including adding and completing health requirements, scheduling appointments, adding documents and retrieving appointments for a specific health requirement.    

Tests can be run in Xcode using **Product → Test**. 
