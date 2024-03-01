//this is a consumer stateful widget for the following purpose:

// ignore_for_file: prefer_const_constructors

/*
The Patient Screen:
At the patient screen, we can set the appointment. The appbar should have the name of the patient, afterwards, we select the type of appointment whether it is an emergency or a visit using the radio buttons. 
Then we will have a description of the diagnosis. Which we will get using a Tex field. We also use a field for the amount charged per visit. On the right side we have an update button to add the visit to the history. 
Then we will have an expandable list tile to view the details of the patient. 
After this we will have the history of the patient which will be an expandable list containing list tiles about the history of the visits.
Afterwards we have the bill section that will show the total bill for the patient and the number of visits. And on the right side we will have the Pay Bills button.
On tapping the pay Bills button an alert dialogue box shows up showing whether we want to pay bills using the insurance or direct method. The entered amount is deducted from the total bill. 

 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:s_sohail/classes_and_vars/buisiness_logic_and_classes.dart';

import 'package:s_sohail/classes_and_vars/temp_ui_classes.dart';
import 'package:s_sohail/services/hospital_services.dart';
import 'package:sqflite/sqflite.dart';

class PatientScreen extends ConsumerStatefulWidget {
  final DatabasePatient patient;
  final HospitalSystem hospitalSystem;

  const PatientScreen({Key? key, required this.patient, required this.hospitalSystem}) : super(key: key);

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends ConsumerState<PatientScreen> {
  late TextEditingController diagnosisController;
  late TextEditingController amountController;

  //creating temporary list of visits
  List<DatabaseVisit> visits = [];

  @override
  void initState() {
    super.initState();
    diagnosisController = TextEditingController();
    amountController = TextEditingController();
    getMyVisits();
  }

  void getMyVisits() {
    visits = widget.hospitalSystem.visits.where((visit) => visit.userId == widget.patient.id).toList();
    setState(() {});
  }

  bool isEmergency = false;

  @override
  void dispose() {
    diagnosisController.dispose();
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //converting the string epoch milliseconds to DateTime
    final DateTime newDate = DateTime.fromMillisecondsSinceEpoch(int.parse(widget.patient.admittedOn));
    return Scaffold(
      appBar: AppBar(
        //increase the app bar size
        toolbarHeight: 100,
        title: Text(widget.patient.name),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            //showing time in 12 hours formate
            title: Text('Admitted on: ${newDate.day}/${newDate.month}/${newDate.year} at ${newDate.hour > 12 ? newDate.hour - 12 : newDate.hour}:${newDate.minute} ${newDate.hour > 12 ? 'PM' : 'AM'} '),
            //total visits
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text('Total visits: ${visits.length}'),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text('Type of appointment'),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(' Emergency'),
                //creating a radio button that will set the isEmergency to true
                Radio(
                  value: true,
                  groupValue: isEmergency,
                  onChanged: (value) {
                    setState(() {
                      isEmergency = value as bool;
                    });
                  },
                ),
                Text('Visit'),
                //creating a radio button that will set the isEmergency to false
                Radio(
                  value: false,
                  groupValue: isEmergency,
                  onChanged: (value) {
                    setState(() {
                      isEmergency = value as bool;
                    });
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title:
                //a Two lined text field with rounded border
                TextField(
              controller: diagnosisController,
              //two lined box
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Diagnosis Details',
                contentPadding: EdgeInsets.all(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          ListTile(
            title: TextField(
              controller: amountController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Rs. (Charges)',
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardType: TextInputType.number,
            ),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text('Update'),
            ),
          ),
          const Divider(),
          ExpansionTile(
            shape: RoundedRectangleBorder(),
            title: Text(
              'Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              ListTile(
                title: Text(
                  'Name: ${widget.patient.name}',
                ),
              ),
              ListTile(
                title: Text('Father Name: '),
              ),
            ],
          ),
          ExpansionTile(
            //remove the border when the expansion tile is expanded
            shape: RoundedRectangleBorder(),

            title: Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Consumer(
                builder: (context, watch, child) {
                  //getting all the table of visit just for testing and displaying all the  visits

                  return Column(
                    children: visits.map((visit) {
                      return ListTile(
                        title: Text('Diagnosis: ${visit.diagnosis}'),
                        subtitle: Text(
                          'Amount charged: ${visit.amount}',
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Bill'),
            children: [
              Consumer(
                builder: (context, watch, child) {
                  // final visits = watch(patientProvider(widget.patient).select((value) => value.visits));
                  return ListTile(
                    title: Text('Total bill: 199'),
                    subtitle: Text('Number of visits: ${visits.length}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        bool isPayedByInsurance = false;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder: (context, setState) {
                              return AlertDialog(
                                //center title
                                title: Center(
                                  child: Text('Pay bills'),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'How would you like to pay?\n',
                                      style: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            //INSURANCE ADD FLUENT ICON
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(Icons.account_balance),
                                            ),
                                            Text(
                                              'Insurance',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            //set isPayedByInsurance to true using radio button
                                            Radio(
                                              value: true,
                                              groupValue: isPayedByInsurance,
                                              onChanged: (value) {
                                                setState(() {
                                                  isPayedByInsurance = value as bool;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            //GIFT CARD ADD FLUENT ICON
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(Icons.monetization_on),
                                            ),

                                            Text(
                                              'Direct      ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            Radio(
                                              value: false,
                                              groupValue: isPayedByInsurance,
                                              onChanged: (value) {
                                                setState(() {
                                                  isPayedByInsurance = value as bool;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        //TODO add  controller
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          hintText: 'Rs.',
                                          contentPadding: EdgeInsets.all(10),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        ],
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Pay'),
                                  ),
                                ],
                              );
                            });
                          },
                        );
                      },
                      child: Text('Pay bills'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
