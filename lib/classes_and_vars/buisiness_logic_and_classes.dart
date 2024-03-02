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

  //getters for the data
  List<DatabasePatient> get patients => _patients;
  List<DatabaseVisit> get visits => _visits;
  List<DatabaseDoctor> get doctors => _doctors;

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

  //Modifying and adding new data:

  Future<void> addNewPatient(String name) async {
    final DatabasePatient newPatient = DatabasePatient(id: _patients.length + 1, name: name, admittedOn: DateTime.now().millisecondsSinceEpoch.toString());
    //time in milliseconds since epoch
    final temp = DateTime.now().millisecondsSinceEpoch;
    await _patientService.createPatient(name: name, admittedOn: temp.toString());
    _patients.add(newPatient);
    notifyListeners();
  }

  Future<void> addNewVisit(String diagnosis, int amount, int patientId, int docId) async {
    final DatabaseVisit newVisit = DatabaseVisit(id: _visits.length + 1, diagnosis: diagnosis, amount: amount, visitDate: DateTime.now().toString(), userId: patientId, docId: docId);
    await _tempVisit.createVisit(diagnosis: diagnosis, amount: amount, visitDate: DateTime.now().toString(), userId: patientId, docId: docId);
    _visits.add(newVisit);
    notifyListeners();
  }

  Future<void> addNewDoctor(String name, String specialization) async {
    final DatabaseDoctor newDoctor = DatabaseDoctor(id: _doctors.length + 1, name: name, specialization: specialization);
    await _tempDoctor.createDoctor(name: name, specialization: specialization);
    _doctors.add(newDoctor);
    notifyListeners();
  }

  //update the visit
  Future<void> updateVisit(DatabaseVisit visit, int amount) async {
    visit.updateVisit(amount: amount, diagnosis: visit.diagnosis, docId: visit.docId, id: visit.id, userId: visit.userId, visitDate: visit.visitDate);
    notifyListeners();
  }
}
