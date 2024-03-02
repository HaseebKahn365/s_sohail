//this is a consumer stateful widget for the following purpose:

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

/*
The Patient Screen:
At the patient screen, we can set the appointment. The appbar should have the name of the patient, afterwards, we select the type of appointment whether it is an emergency or a visit using the radio buttons. 
Then we will have a description of the diagnosis. Which we will get using a Tex field. We also use a field for the amount charged per visit. On the right side we have an update button to add the visit to the history. 
Then we will have an expandable list tile to view the details of the patient. 
After this we will have the history of the patient which will be an expandable list containing list tiles about the history of the visits.
Afterwards we have the bill section that will show the total bill for the patient and the number of visits. And on the right side we will have the Pay Bills button.
On tapping the pay Bills button an alert dialogue box shows up showing whether we want to pay bills using the insurance or direct method. The entered amount is deducted from the total bill. 

 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:s_sohail/classes_and_vars/buisiness_logic_and_classes.dart';

import 'package:s_sohail/services/hospital_services.dart';

class PatientScreen extends ConsumerStatefulWidget {
  final DatabasePatient patient;
  final HospitalSystem hospitalSystem;
  final DatabaseDoctor selectedDoctor;

  const PatientScreen({Key? key, required this.patient, required this.hospitalSystem, required this.selectedDoctor}) : super(key: key);

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

  Future<void> refresh() async {
    await widget.hospitalSystem.initDatabase();
    setState(() {
      getMyVisits();
    });
  }

  void getMyVisits() {
    visits = widget.hospitalSystem.visits.where((visit) => visit.userId == widget.patient.id).toList();
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
              padding: const EdgeInsets.only(top: 13.0, bottom: 8),
              child: Text('Total Appointments: ${visits.length}'),
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
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
              onPressed: () async {
                //check if the diagnosis and amount is not empty
                if (diagnosisController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  //add the visit to the history
                  widget.hospitalSystem.addNewVisit(diagnosisController.text, int.parse(amountController.text), widget.patient.id, widget.selectedDoctor.id);
                  //clear the text fields
                  diagnosisController.clear();
                  amountController.clear();
                  await widget.hospitalSystem.initDatabase();
                  setState(() {
                    getMyVisits();
                  });
                  //get the visits
                }
              },
              child: Text('Update'),
            ),
          ),
          const Divider(),
          ExpansionTile(
            shape: RoundedRectangleBorder(),
            title: Row(
              children: [
                //details icon
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 5),
                  child: Icon(
                    FluentIcons.data_usage_edit_24_regular,
                    size: 30,
                  ),
                ),
                Text(
                  'Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            children: [
              ListTile(
                title: Text(
                  'Name: ${widget.patient.name}',
                ),
              ),
              ListTile(
                title: Text('Father Name: Nade Zaroori'),
              ),
            ],
          ),
          ExpansionTile(
            //remove the border when the expansion tile is expanded
            shape: RoundedRectangleBorder(),

            title: Row(
              children: [
                //history icon
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 5),
                  child: Icon(
                    FluentIcons.history_24_regular,
                    size: 30,
                  ),
                ),
                Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
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
                              trailing: Text("Consulted by: ${(visit.docId == 1) ? "Dr. Sohail" : "Haseeb"}"))
                          .animate(effects: [
                        //applying the animation
                        FadeEffect(
                          //setting the duration of the animation
                          duration: Duration(milliseconds: 500),
                          delay: Duration(milliseconds: 300 * visits.indexOf(visit)),
                        ),
                      ]);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            title: Row(
              children: [
                //credit card person icon
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 5),
                  child: Icon(
                    FluentIcons.credit_card_person_24_regular,
                    size: 30,
                  ),
                ),
                Text(
                  'Bill',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            children: [
              Consumer(
                builder: (context, watch, child) {
                  // final visits = watch(patientProvider(widget.patient).select((value) => value.visits));
                  return ListTile(
                    title: Text('Total bill: ${visits.fold(0, (previousValue, element) => previousValue + element.amount)}'),
                    subtitle: Text('Number of Appointments: ${visits.length}'),
                    trailing: ElevatedButton(
                            onPressed: () {
                              bool isPayedByInsurance = false;
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(builder: (context, setState) {
                                    TextEditingController paymentcontroller = TextEditingController();
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
                                              controller: paymentcontroller,
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
                                          onPressed: () async {
                                            //go through the entire list of visits and keep on subtracting the amount from amount of each visit then update the database
                                            int paymentAmount = int.parse(paymentcontroller.text);
                                            int totalDues = visits.fold(0, (previousValue, element) => previousValue + element.amount);
                                            print("Payments amount: $paymentAmount");
                                            print("Total dues: $totalDues");
                                            if (paymentAmount > totalDues) {
                                              //show snalck bar that you have payed all the bills
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Row(
                                                  children: [
                                                    Text('You have payed all the bills\nTake back your ${paymentAmount - totalDues}     '),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 20.0),
                                                      child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.surface),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                            }
                                            for (var visit in visits) {
                                              if (paymentAmount > 0) {
                                                if (paymentAmount >= visit.amount) {
                                                  paymentAmount -= visit.amount;
                                                  visit.updateVisit(amount: 0, diagnosis: visit.diagnosis, docId: visit.docId, id: visit.id, userId: visit.userId, visitDate: visit.visitDate);
                                                } else {
                                                  visit.updateVisit(amount: visit.amount - paymentAmount, diagnosis: visit.diagnosis, docId: visit.docId, id: visit.id, userId: visit.userId, visitDate: visit.visitDate);
                                                  paymentAmount = 0;
                                                }
                                              }
                                            }
                                            await refresh();
                                            Navigator.pop(context);
                                          },
                                          child: Text('Pay').animate(),
                                        ),
                                      ],
                                    );
                                  }).animate(
                                    effects: [
                                      //fade then shimmer
                                      FadeEffect(
                                        duration: Duration(milliseconds: 300),
                                        delay: Duration(milliseconds: 80),
                                      ),

                                      ShimmerEffect(
                                        duration: Duration(milliseconds: 600),
                                        //if in light mode show theme.of(context).inverseSurface else show white
                                        color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.3) : Colors.white,
                                        delay: Duration(milliseconds: 300),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Pay bills'))
                        .animate(effects: [
                      ScaleEffect(
                        duration: Duration(milliseconds: 200),
                        delay: Duration(milliseconds: 80),
                      ),
                    ]),
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
