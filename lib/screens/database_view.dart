//here we display all the tables of the database from the lists that are present in the instance of the hospitalSystem class which will be passed as a parameter to this screen

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

//here is what the data looks like:

/*
[Patient{id: 1, name: haseeb, admittedOn: 1709375481405}, Patient{id: 2, name: uzair, admittedOn: 1709375491921}, Patient{id: 3, name: tayyab, admittedOn: 1709375497250}, Patient{id: 4, name: Bilal, admittedOn: 1709375529979}, Patient{id: 5, name: bump, admittedOn: 1709386732213}]
I/flutter (31888): [Visit{id: 1, amount: 0, diagnosis: Panadol , userId: 1, docId: 1, visitDate: 2024-03-02 15:32:25.848915}, Visit{id: 2, amount: 0, diagnosis: Antibiotics , userId: 1, docId: 1, visitDate: 2024-03-02 15:32:38.780794}, Visit{id: 3, amount: 0, diagnosis: Dextroamphetamine , userId: 3, docId: 1, visitDate: 2024-03-02 15:33:28.368813}, Visit{id: 4, amount: 77, diagnosis: methamphetamine 
I/flutter (31888): 🍷, userId: 3, docId: 1, visitDate: 2024-03-02 15:45:43.839325}]
I/flutter (31888): [Doctor{id: 1, name: Dr. Sohail, specialization: General Physician}, Doctor{id: 2, name: Haseeb, specialization: General Surgeon}]
 */
class DatabaseTableView extends StatefulWidget {
  const DatabaseTableView({super.key, required this.hospitalSystem});
  final hospitalSystem;

  @override
  State<DatabaseTableView> createState() => _TableViewDatabaseState();
}

class _TableViewDatabaseState extends State<DatabaseTableView> {
  @override
  Widget build(BuildContext context) {
    print(widget.hospitalSystem.patients);
    print(widget.hospitalSystem.visits);
    print(widget.hospitalSystem.doctors);
    //we are going to use tables wrapped in an interactive viewer as body to display the tables
    return Scaffold(
        appBar: AppBar(
          title: const Text('Database Tables'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Patients'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 35,
                        dataRowHeight: 35,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Row(
                              children: [
                                //add an icon for primary keyy
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    FluentIcons.key_multiple_20_regular,
                                    size: 15,
                                  ),
                                ),
                                Text('ID'),
                              ],
                            ),
                          ),
                          DataColumn(
                            label: Text('Name'),
                          ),
                          DataColumn(
                            label: Text('Admitted On'),
                          ),
                        ],
                        rows: [
                          // DataRow(cells: [DataCell(Text('1')), DataCell(Text('haseeb')), DataCell(Text('1709375481405'))])
                          for (var patient in widget.hospitalSystem.patients)
                            DataRow(cells: [
                              DataCell(Text(patient.id.toString())),
                              DataCell(Text(patient.name)),
                              DataCell(Text(patient.admittedOn)),
                            ]),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Visits'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        child: DataTable(
                          headingRowHeight: 35,
                          dataRowHeight: 35,
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Row(
                                children: [
                                  //add an icon for primary keyy
                                  Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      FluentIcons.key_multiple_20_regular,
                                      size: 15,
                                    ),
                                  ),
                                  Text('ID'),
                                ],
                              ),
                            ),
                            DataColumn(
                              label: Text('Amount'),
                            ),
                            DataColumn(
                              label: Text('Diagnosis'),
                            ),
                            DataColumn(
                              label: Row(
                                children: [
                                  //add an icon for primary keyy
                                  Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      FluentIcons.key_multiple_20_regular,
                                      size: 15,
                                    ),
                                  ),
                                  Text('Patient FK'),
                                ],
                              ),
                            ),
                            DataColumn(
                              label: Row(
                                children: [
                                  //add an icon for primary keyy
                                  Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      FluentIcons.key_multiple_20_regular,
                                      size: 15,
                                    ),
                                  ),
                                  Text('Doctor FK'),
                                ],
                              ),
                            ),
                            DataColumn(
                              label: Text('Visit Date'),
                            ),
                          ],
                          rows: [
                            for (var visit in widget.hospitalSystem.visits)
                              DataRow(cells: [
                                DataCell(Text(visit.id.toString())),
                                DataCell(Text(visit.amount.toString())),
                                DataCell(Text(visit.diagnosis)),
                                DataCell(Text(visit.userId.toString(), style: TextStyle(color: widget.hospitalSystem.patients.indexWhere((element) => element.id == visit.userId) == -1 ? Colors.red : Colors.black) // this is the patient id we should make it appear red in case if the patient is deleted in other words we can't find its id in the patients list
                                    )), // this is the patient id we should make it appear red in case if the patient is deleted in other words we can't find its id in the patients list
                                DataCell(Text(visit.docId.toString())),
                                DataCell(Text(visit.visitDate)),
                              ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Doctors'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 35,
                        dataRowHeight: 35,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Row(
                              children: [
                                //add an icon for primary keyy
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    FluentIcons.key_multiple_20_regular,
                                    size: 15,
                                  ),
                                ),
                                Text('ID'),
                              ],
                            ),
                          ),
                          DataColumn(
                            label: Text('Name'),
                          ),
                          DataColumn(
                            label: Text('Specialization'),
                          ),
                        ],
                        rows: [
                          for (var doctor in widget.hospitalSystem.doctors)
                            DataRow(cells: [
                              DataCell(Text(doctor.id.toString())),
                              DataCell(Text(doctor.name)),
                              DataCell(Text(doctor.specialization)),
                            ]),
                        ],
                      ),
                    ),
                  ),

                  //creating a very similar table for the deleted Patients
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Deleted Patients'),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 35,
                        dataRowHeight: 35,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Row(
                              children: [
                                //add an icon for primary keyy
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    FluentIcons.key_multiple_20_regular,
                                    size: 15,
                                  ),
                                ),
                                Text('ID'),
                              ],
                            ),
                          ),
                          DataColumn(
                            label: Text('Name'),
                          ),
                          DataColumn(
                            label: Text('Admitted On'),
                          ),
                        ],
                        rows: [
                          // DataRow(cells: [DataCell(Text('1')), DataCell(Text('haseeb')), DataCell(Text('1709375481405'))])
                          for (var patient in widget.hospitalSystem.deletedPatients)
                            DataRow(cells: [
                              DataCell(Text(patient.id.toString())),
                              DataCell(Text(patient.name)),
                              DataCell(Text(patient.admittedOn)),
                            ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
