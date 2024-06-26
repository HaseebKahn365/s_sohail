/*

Buisiness Logic and UI classes:
We are going to have a central Hospital System class that will be used for managing all the state of the application as well as the operations on the Database



 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:s_sohail/services/hospital_services.dart';

class HospitalSystem extends ChangeNotifier {
  List<DatabasePatient> _patients = [];
  List<DatabaseVisit> _visits = [];
  List<DatabaseDoctor> _doctors = [];
  List<DatabasePatient> deletedPatients = [];

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
    log("Trying to open the database and get the patients");
    await _patientService.open();
    _patients = await _patientService.getAllPatients();
    log("Got the patients");
    _visits = await _tempVisit.getAllVisits();
    log("Got the visits");
    _doctors = await _tempDoctor.getAllDoctors();
    log("Got the doctors");

    deletedPatients = await _patientService.getDeletedPatients();
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

  //deleting the patient with triggers so that we can see the patient in the deleted patients list

  Future<void> deletePatient(int id) async {
    final DatabasePatient patient = _patients.firstWhere((element) => element.id == id);

    //delete the patient
    await _patientService.createDeleteTriggerAndDelete();
    //actually delete the patient
    await _patientService.deletePatientWithID(id);
    _patients.remove(patient);
    deletedPatients.add(patient);

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
    await _tempDoctor.createDoctor(name: name, specialization: specialization);
    //querry to get the last doctor
    notifyListeners();
  }

  //update the visit
  Future<void> updateVisit(DatabaseVisit visit, int amount) async {
    visit.updateVisit(amount: amount, diagnosis: visit.diagnosis, docId: visit.docId, id: visit.id, userId: visit.userId, visitDate: visit.visitDate);
    notifyListeners();
  }
}


//The following structure is a redesign of this buisiness logic. we will use the concepts of generalization, inheritance, and decomposition to make the code more modular and reusable.
/*
THe following structure describes the new dessign

speaking of doctor there is a doctor class which has has children as ContractDoctor and PermanentDoctor
the patient class has children as InPatient and OutPatient

the aggregatioon of the hospital class is with the child classes of the patient class and the doctor class

along with these classes there is a visit class which has a composition with the doctor and patient classes

this above is the entire structure of the hospital system, now lets add the attributes and methods to these classes

!Hospital class

Attributes:
- List<ContractDoctor> contractDoctors
- List<PermanentDoctor> permanentDoctors
- List<InPatient> inPatients
- List<OutPatient> outPatients

Methods:
- addContractDoctor
- addPermanentDoctor
- addInPatient
- addOutPatient

!Doctor class

Attributes:
- int id
- String name
- String specialization

Methods:
- updateDoctor

!ContractDoctor class

Attributes:
- int contractPeriod

Methods:
- updateContractDoctor

!PermanentDoctor class

Attributes:
- int salary

Methods:
- updatePermanentDoctor

!Patient class

Attributes:
- int id
- String name

Methods:
- updatePatient

!InPatient class

Attributes:
- DateTime admittedOn

Methods:
- updateInPatient

!OutPatient class

Attributes:
- DateTime lastVisit

Methods:
- updateOutPatient

!Visit class

Attributes:
- int id
- String diagnosis
- int amount
- DateTime visitDate
- Doctor doctor
- Patient patient

Methods:
- updateVisit

 */