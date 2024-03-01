/*
Introduction:
This is a simple flutter application that is primarily designed for reading and writing data to a local database for persistent storage. The purpose is to take the data related to the patient and store it on a relational database using the SQflite package available as a package for flutter.
Here is an overview of what the interface is going to look like: 
The name of the hospital is S.Sohail Hospital
Home screen overview:
At the home screen we will have a search in the app bar then the list view of the list tiles for the patients. We can add a patient using the floating action button. Here is what happens when we tap the floating action button. An alert dialogue box appears asking for the basic details about the patient. When the patient is created, it appears on the home screen as the listview updates.
On tapping the List tile of the patient, we should be navigated to the patient screen, where we are going to be able to see the patient’s information which is specified below:

The Patient Screen:
At the patient screen, we can set the appointment. The appbar should have the name of the patient, afterwards, we select the type of appointment whether it is an emergency or a visit using the radio buttons. 
Then we will have a description of the diagnosis. Which we will get using a Tex field. We also use a field for the amount charged per visit. On the right side we have an update button to add the visit to the history. 
Then we will have an expandable list tile to view the details of the patient. 
After this we will have the history of the patient which will be an expandable list containing list tiles about the history of the visits.
Afterwards we have the bill section that will show the total bill for the patient and the number of visits. And on the right side we will have the Pay Bills button.
On tapping the pay Bills button an alert dialogue box shows up showing whether we want to pay bills using the insurance or direct method. The entered amount is deducted from the total bill. 

 */

//this is a temporary class for patient
class Patient {
  String name;
  DateTime admittedOn;

  Patient({required this.name, required this.admittedOn});
}

//temporary class for visit
class Visit {
  String diagnosis;
  double amountCharged;
  DateTime date;

  Visit({required this.diagnosis, required this.amountCharged, required this.date});
}
