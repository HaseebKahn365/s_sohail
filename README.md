# s_sohail

## Introduction
This is a simple Flutter application designed for reading and writing data to a local database for persistent storage. The main functionality revolves around managing patient data for S. Sohail Hospital. It utilizes the SQflite package for database management within the Flutter framework.

## Application Overview
The application interface revolves around managing patient data. Here's an overview of the key features:

### Home Screen
- The home screen features a search bar in the app bar and a list view of patients.
- Users can add new patients using the floating action button, which prompts an alert dialogue for entering basic patient details.
- Tapping on a patient's list tile navigates to the patient screen.

### Patient Screen
- The patient screen displays detailed information about a selected patient.
- It includes an app bar with the patient's name, appointment type selection (emergency or visit), diagnosis description input, and amount charged per visit.
- Users can update and view detailed patient information.
- It also showcases the patient's visit history, allowing users to view past visits and their details.
- A bill section displays the total bill for the patient and provides an option to pay bills either through insurance or direct method.

## Implementation Details
The application is implemented using the following key components:

### `HospitalSystem` Class
- Manages patient, visit, and doctor data.
- Provides methods for initializing the database, adding new patients, visits, and doctors, updating visits, and deleting the entire database.
- Utilizes `ChangeNotifier` for state management.

### `DatabasePatient`, `DatabaseVisit`, and `DatabaseDoctor` Classes
- Represents the data models for patients, visits, and doctors respectively.

### `PatientService` Class
- Handles database operations such as creating, retrieving, and deleting patient data.

## Usage
To use the application:
1. Ensure Flutter environment is set up.
2. Clone the repository.
3. Run the application on a compatible device or emulator.

## Contributing
Contributions are welcome! Feel free to submit pull requests or open issues for any bugs or feature requests.

## License
This project is licensed under the [MIT License](LICENSE).

