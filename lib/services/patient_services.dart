//here we perform all the CRUD operations for the patient and visits
/*
Here is the structure of the database:
CREATE TABLE `Patient` (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`name`	TEXT NOT NULL,
	`admitted_on`	TEXT NOT NULL
);

CREATE TABLE `Visit` (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`amount`	INTEGER NOT NULL,
	`diagnosis`	TEXT NOT NULL,
	`user_id`	INTEGER NOT NULL,
	FOREIGN KEY(`user_id`) REFERENCES `Patient`(`id`)
);


 */

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
    print('created patient inside the db: $createdPatient');
    return createdPatient;
  }

  Future<void> deletePatient(int id) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(patientTable, where: '$idColumn = ?', whereArgs: [id]);
    if (deleteCount != 1) {
      throw 'Error deleting patient';
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw 'Database already open';
    }
    try {
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
        await db.execute('''
        CREATE TABLE IF NOT EXISTS $visitTable (
          $idColumn INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          $amountColumn INTEGER NOT NULL,
          $diagnosisColumn TEXT NOT NULL,
          $userIdColumn INTEGER NOT NULL,
          FOREIGN KEY($userIdColumn) REFERENCES $patientTable($idColumn)
        );
        ''');
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
  final int userId;

  DatabaseVisit({required this.id, required this.amount, required this.diagnosis, required this.userId});

  //fetch all visits with a particular patient id
  Future<List<DatabaseVisit>> getVisitsForPatient(int userId) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(visitTable, where: '$userIdColumn = ?', whereArgs: [userId]);
    return results.map((e) => DatabaseVisit.fromRow(e)).toList();
  }

  //update a particular visit using patient id and visit id
  Future<void> updateVisit({required int id, required int amount, required String diagnosis, required int userId}) async {
    final db = _getDatabaseOrThrow();
    final updateCount = await db.update(visitTable, {amountColumn: amount, diagnosisColumn: diagnosis, userIdColumn: userId}, where: '$idColumn = ?', whereArgs: [id]);
    if (updateCount != 1) {
      throw 'Error updating visit';
    }
  }

  //create visit
  Future<DatabaseVisit> createVisit({required int amount, required String diagnosis, required int userId}) async {
    final db = _getDatabaseOrThrow();
    final id = await db.insert(visitTable, {amountColumn: amount, diagnosisColumn: diagnosis, userIdColumn: userId});
    final dbVisit = DatabaseVisit(id: id, amount: amount, diagnosis: diagnosis, userId: userId);
    print('created visit inside the db: $dbVisit');
    return dbVisit;
  }

  //named constructor for visit from database row
  DatabaseVisit.fromRow(Map<String, dynamic> map)
      : id = map[idColumn] as int,
        amount = map[amountColumn] as int,
        diagnosis = map[diagnosisColumn] as String,
        userId = map[userIdColumn] as int;

  //implementing toString
  @override
  String toString() {
    return 'Visit{id: $id, amount: $amount, diagnosis: $diagnosis, userId: $userId}';
  }

  //implementing the equality operator

  @override
  bool operator ==(covariant DatabaseVisit other) {
    return id == other.id && amount == other.amount && diagnosis == other.diagnosis && userId == other.userId;
  }
}

//creating consts for the fields of the database:
const idColumn = 'id';
const nameColumn = 'name';
const admittedOnColumn = 'admitted_on';
const amountColumn = 'amount';
const diagnosisColumn = 'diagnosis';
const userIdColumn = 'user_id';

//consts for database name
const dbName = 'patient.db';
const patientTable = 'Patient';
const visitTable = 'Visit';
