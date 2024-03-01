/*

Buisiness Logic and UI classes:
We are going to have a central Hospital System class that will be used for managing all the state of the application as well as the operations on the Database



 */

import 'package:flutter/material.dart';
import 'package:s_sohail/services/hospital_services.dart';

class HospitalSystem extends ChangeNotifier {
  List<DatabasePatient> _patients = [];
  List<DatabaseVisit> _visits = [];
  List<DatabaseDoctor> _doctors = [];

  //temporary visit and doctor objects for getting the data
  final DatabaseVisit _tempVisit = DatabaseVisit(diagnosis: 'Fever', docId: 1, amount: 1000, id: 1, userId: 1, visitDate: DateTime.now().toString());
  final DatabaseDoctor _tempDoctor = DatabaseDoctor(id: 1, name: 'Dr. Sohail', specialization: 'General Physician');

  final PatientService _patientService = PatientService();

  //initializing the database
  Future<void> initDatabase() async {
    print("Trying to open the database and get the patients");
    await _patientService.open();
    _patients = await _patientService.getAllPatients();
    print("Got the patients");
    _visits = await _tempVisit.getAllVisits();
    print("Got the visits");
    _doctors = await _tempDoctor.getAllDoctors();
    print("Got the doctors");
    notifyListeners();
  }

  //deleteEntireDatabase
  Future<void> deleteEntireDatabase() async {
    try {
      await _patientService.deleteAllDb();
      print("Deleted the entire database");
    } catch (e) {
      print("Error in deleting the entire database");
    }
    _patients = [];
    _visits = [];
    _doctors = [];
    notifyListeners();
  }
}
