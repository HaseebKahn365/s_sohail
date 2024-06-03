import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _db;

Database _getDatabaseOrThrow() {
  final db = _db;
  if (db == null) {
    throw 'Database not open';
  } else {
    return db;
  }
}

class PatientService {
  //get all patients
  Future<List<DatabasePatient>> getAllPatients() async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(patientTable);
    return results.map((e) => DatabasePatient.fromRow(e)).toList();
  }

  Future<DatabasePatient> createPatient({required String name, required String admittedOn}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      patientTable,
      limit: 1,
      where: '$nameColumn = ? AND $admittedOnColumn = ?',
      whereArgs: [name, admittedOn],
    );
    if (results.isNotEmpty) {
      throw 'Patient already exists';
    }
    final id = await db.insert(patientTable, {nameColumn: name, admittedOnColumn: admittedOn});

    final createdPatient = DatabasePatient(id: id, name: name, admittedOn: admittedOn);
    log('created patient inside the db: $createdPatient');
    return createdPatient;
  }

  //! new methods added after update

  //getting all the deleted patients
  Future<List<DatabasePatient>> getDeletedPatients() async {
    final db = _getDatabaseOrThrow();
    final results = await db.query('DeletedPatient');
    return results.map((e) => DatabasePatient.fromRow(e)).toList();
  }

  //delete patient with id
  //  await _patientService.deletePatientWithID(id);

  Future<void> deletePatientWithID(int id) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(patientTable, where: '$idColumn = ?', whereArgs: [id]);
    if (deleteCount != 1) {
      throw 'Error deleting patient';
    }
  }

  Future<void> createDeleteTriggerAndDelete() async {
    final db = _getDatabaseOrThrow();
    //create deleted patients table if not exists and also create trigger if not exists

    try {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS DeletedPatient (
        $idColumn INTEGER NOT NULL PRIMARY KEY,
        $nameColumn TEXT NOT NULL,
        $admittedOnColumn TEXT NOT NULL
      );
      ''');

      log('Created a new deleted patient table successfully');
    } catch (e) {
      log('Error creating deleted patient table: $e');
    }

    try {
      //!copied from today's classwork
      await db.execute('''
      CREATE TRIGGER IF NOT EXISTS delete_patient_trigger
      AFTER DELETE ON $patientTable
      BEGIN
        INSERT INTO DeletedPatient ($idColumn, $nameColumn, $admittedOnColumn)
        VALUES (OLD.$idColumn, OLD.$nameColumn, OLD.$admittedOnColumn);
      END;
      ''');

      log('Created a new delete trigger successfully');
    } catch (e) {
      log('Error creating delete trigger: $e');
    }
  }

  Future<void> open() async {
    if (_db != null) {
      return;
    }
    try {
      log("Creating new database for patients");
      final docsPath = await getDatabasesPath();
      final dbPath = join(docsPath, dbName);
      _db = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS $patientTable (
          $idColumn INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          $nameColumn TEXT NOT NULL,
          $admittedOnColumn TEXT NOT NULL
        );
        ''');

        print("Creating new database for visits");
        await db.execute('''
        CREATE TABLE IF NOT EXISTS $visitTable (
          $idColumn INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          $amountColumn INTEGER NOT NULL,
          $diagnosisColumn TEXT NOT NULL,
          $userIdColumn INTEGER NOT NULL,
          $docIdColumn INTEGER NOT NULL,
          $visitDateColumn TEXT NOT NULL,
          FOREIGN KEY($userIdColumn) REFERENCES $patientTable($idColumn)
        );
        ''');
        print("Creating new database for doctors");

        await db.execute('''
        CREATE TABLE IF NOT EXISTS $doctorTable (
          $idColumn INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          $nameColumn TEXT NOT NULL,
          $specializationColumn TEXT NOT NULL
        );
        ''');

        print("Creating new database for deleted doctors");

        await db.execute('''
        CREATE TABLE IF NOT EXISTS DeletedDoctor (
          $idColumn INTEGER NOT NULL PRIMARY KEY,
          $nameColumn TEXT NOT NULL,
          $specializationColumn TEXT NOT NULL
        );
        ''');

        log("Database created successfully");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> close() async {
    if (_db == null) {
      throw 'Database already closed';
    }
    await _db!.close();
    _db = null;
  }

  //delete the entire database
  Future<void> deleteAllDb() async {
    print("Deleting all the database");
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    final docsPath = await getDatabasesPath();
    final dbPath = join(docsPath, dbName);
    await deleteDatabase(dbPath);
  }
}

class DatabasePatient {
  final int id;
  final String name;
  final String admittedOn;

  DatabasePatient({required this.id, required this.name, required this.admittedOn});

  //named constructor for patient from database row
  DatabasePatient.fromRow(Map<String, dynamic> map)
      : id = map[idColumn] as int,
        name = map[nameColumn] as String,
        admittedOn = map[admittedOnColumn] as String;

//implementing toString
  @override
  String toString() {
    return 'Patient{id: $id, name: $name, admittedOn: $admittedOn}';
  }

  //implementing the equality operator

  @override
  bool operator ==(covariant DatabasePatient other) {
    return id == other.id && name == other.name && admittedOn == other.admittedOn;
  }
}

//class for visit

class DatabaseVisit {
  final int id;
  final int amount;
  final String diagnosis;
  final String visitDate; //this is the string representation of the time since epoch
  final int userId;
  final int docId;

  DatabaseVisit({required this.id, required this.amount, required this.diagnosis, required this.userId, required this.docId, required this.visitDate});

  //fetch all visits with a particular patient id
  Future<List<DatabaseVisit>> getVisitsForPatient(int userId) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(visitTable, where: '$userIdColumn = ?', whereArgs: [userId]);
    return results.map((e) => DatabaseVisit.fromRow(e)).toList();
  }

  //update a particular visit using patient id and visit id
  Future<void> updateVisit({required int id, required int amount, required String diagnosis, required int userId, required int docId, required String visitDate}) async {
    final db = _getDatabaseOrThrow();
    final updateCount = await db.update(visitTable, {amountColumn: amount, diagnosisColumn: diagnosis, userIdColumn: userId, docIdColumn: docId, visitDateColumn: visitDate}, where: '$idColumn = ?', whereArgs: [id]);
    log('updated visit inside the db: $updateCount');
    log('updated visit details: $id, $amount, $diagnosis, $userId, $docId, $visitDate');
    if (updateCount != 1) {
      throw 'Error updating visit';
    }
  }

  //getAllVisits from the table of visits and return a List of DatabaseVisit
  Future<List<DatabaseVisit>> getAllVisits() async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(visitTable);
    return results.map((e) => DatabaseVisit.fromRow(e)).toList();
  }

  //create visit
  Future<DatabaseVisit> createVisit({required int amount, required String diagnosis, required int userId, required int docId, required String visitDate}) async {
    final db = _getDatabaseOrThrow();
    final id = await db.insert(visitTable, {amountColumn: amount, diagnosisColumn: diagnosis, userIdColumn: userId, docIdColumn: docId, visitDateColumn: visitDate});
    final dbVisit = DatabaseVisit(id: id, amount: amount, diagnosis: diagnosis, userId: userId, docId: docId, visitDate: visitDate);
    log('created visit inside the db: $dbVisit');
    return dbVisit;
  }

  //named constructor for visit from database row
  DatabaseVisit.fromRow(Map<String, dynamic> map)
      : id = map[idColumn] as int,
        amount = map[amountColumn] as int,
        diagnosis = map[diagnosisColumn] as String,
        userId = map[userIdColumn] as int,
        docId = map[docIdColumn] as int,
        visitDate = map[visitDateColumn] as String;

  //implementing toString
  @override
  String toString() {
    return 'Visit{id: $id, amount: $amount, diagnosis: $diagnosis, userId: $userId, docId: $docId, visitDate: $visitDate}';
  }

  //implementing the equality operator

  @override
  bool operator ==(covariant DatabaseVisit other) {
    return id == other.id && amount == other.amount && diagnosis == other.diagnosis && userId == other.userId;
  }
}

//similar to the visit now we will create the DatabaseDoctor

class DatabaseDoctor {
  final int id;
  final String name;
  final String specialization;

  DatabaseDoctor({required this.id, required this.name, required this.specialization});

  //fetch all doctors
  Future<List<DatabaseDoctor>> getAllDoctors() async {
    final db = _getDatabaseOrThrow();
    //only getting the doctors with id 1 or 2
    final results = await db.query(
      doctorTable,
      where: '$idColumn = ? OR $idColumn = ?', //sql-injection secure
      whereArgs: [1, 2],
    );
    return results.map((e) => DatabaseDoctor.fromRow(e)).toList();
  }

  Future<void> checkNumber() async {
    final db = _getDatabaseOrThrow();
    //use aggregate function count()
    final results = await db.rawQuery('SELECT COUNT(*) FROM $doctorTable');
    log('Number of doctors: ${results[0].values}');
  }

  //create doctor
  Future<DatabaseDoctor> createDoctor({required String name, required String specialization}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      doctorTable,
      limit: 1,
      where: '$nameColumn = ? AND $specializationColumn = ?',
      whereArgs: [name, specialization],
    );
    if (results.isNotEmpty) {
      throw 'Doctor already exists';
    }
    final id = await db.insert(doctorTable, {nameColumn: name, specializationColumn: specialization});
    final dbDoctor = DatabaseDoctor(id: id, name: name, specialization: specialization);
    log('created new doctor inside the db: $dbDoctor');
    return dbDoctor;
  }

  //named constructor for doctor from database row
  DatabaseDoctor.fromRow(Map<String, dynamic> map)
      : id = map[idColumn] as int,
        name = map[nameColumn] as String,
        specialization = map[specializationColumn] as String;

  //implementing toString
  @override
  String toString() {
    return 'Doctor{id: $id, name: $name, specialization: $specialization}';
  }

  //implementing the equality operator

  @override
  bool operator ==(covariant DatabaseDoctor other) {
    return id == other.id && name == other.name && specialization == other.specialization;
  }
}

//creating consts for the fields of the database:
const idColumn = 'id';
const nameColumn = 'name';
const admittedOnColumn = 'admitted_on';
const amountColumn = 'amount';
const diagnosisColumn = 'diagnosis';
const userIdColumn = 'user_id';
const docIdColumn = 'doc_id';
const specializationColumn = 'specialization';
const visitDateColumn = 'visit_date';

//consts for database name
const dbName = 'patient.db';
const patientTable = 'Patient';
const visitTable = 'Visit';
const doctorTable = 'Doctor';
