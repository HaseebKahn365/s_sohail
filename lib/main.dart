// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, must_be_immutable

// Introduction:
// This is a simple flutter application that is primarily designed for reading and writing data to a local database for persistent storage. The purpose is to take the data related to the patient and store it on a relational database using the SQflite package available as a package for flutter.
// Here is an overview of what the interface is going to look like:
// The name of the hospital is S.Sohail Hospital
// Home screen overview:
// At the home screen we will have a search in the app bar then the list view of the list tiles for the patients. We can add a patient using the floating action button. Here is what happens when we tap the floating action button. An alert dialogue box appears asking for the basic details about the patient. When the patient is created, it appears on the home screen as the listview updates.
// On tapping the List tile of the patient, we should be navigated to the patient screen, where we are going to be able to see the patient’s information which is specified below:

// The Patient Screen:
// At the patient screen, we can set the appointment. The appbar should have the name of the patient, afterwards, we select the type of appointment whether it is an emergency or a visit using the radio buttons.
// Then we will have a description of the diagnosis. Which we will get using a Tex field. We also use a field for the amount charged per visit. On the right side we have an update button to add the visit to the history.
// Then we will have an expandable list tile to view the details of the patient.
// After this we will have the history of the patient which will be an expandable list containing list tiles about the history of the visits.
// Afterwards we have the bill section that will show the total bill for the patient and the number of visits. And on the right side we will have the Pay Bills button.
// On tapping the pay Bills button an alert dialogue box shows up showing whether we want to pay bills using the insurance or direct method. The entered amount is deducted from the total bill.

import 'package:flutter/material.dart';
import 'package:s_sohail/classes_and_vars/buisiness_logic_and_classes.dart';
import 'package:s_sohail/classes_and_vars/temp_ui_classes.dart';
import 'package:s_sohail/screens/patient_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/hospital_services.dart';

void main() {
  //using riverpod provider scope
  runApp(
    ProviderScope(
      child: SSohailHospital(),
    ),
  );
}

late final PatientService patientService;

class SSohailHospital extends ConsumerStatefulWidget {
  const SSohailHospital({Key? key}) : super(key: key);

  @override
  _SSohailHospitalState createState() => _SSohailHospitalState();
}

const double narrowScreenWidthThreshold = 450;

const Color m3BaseColor = Color(0xff6750a4);
const List<Color> colorOptions = [
  m3BaseColor,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
  Colors.lime,
  Colors.red,
  Colors.purple,
  Colors.brown,
  Colors.cyan,
  Colors.indigo,
  Colors.amber,
];
const List<String> colorText = <String>["M3 Baseline", "Blue", "Teal", "Green", "Yellow", "Orange", "Pink", "Lime"];

class _SSohailHospitalState extends ConsumerState<SSohailHospital> {
  bool useMaterial3 = true;
  bool useLightMode = true;
  int colorSelected = 0;
  int screenIndex = 0;

  late ThemeData themeData;

  List<DatabasePatient> patientList = [];

  @override
  initState() {
    super.initState();
    themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
  }

  //

  ThemeData updateThemes(int colorIndex, bool useMaterial3, bool useLightMode) {
    return ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      useMaterial3: useMaterial3,
      brightness: useLightMode ? Brightness.light : Brightness.dark,
    );
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void handleBrightnessChange() {
    setState(() {
      useLightMode = !useLightMode;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelected = value;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'S. Sohail Hospital',
      themeMode: useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: themeData,
      home: HomeScreen(
        useLightMode: useLightMode,
        handleBrightnessChange: handleBrightnessChange,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool useLightMode;
  final VoidCallback handleBrightnessChange;

  HomeScreen({
    Key? key,
    required this.useLightMode,
    required this.handleBrightnessChange,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //creating a hospital system object
  final HospitalSystem hospitalSystemObject = HospitalSystem();
  @override
  void initState() {
    super.initState();
    // patientService = PatientService();
    // patientService.open();
    bigFuture();
    print('Creating a doctor');
  }

  DatabaseDoctor d1 = DatabaseDoctor(name: 'Dr. Sohail', specialization: 'General Physician', id: 1);
  DatabaseDoctor d2 = DatabaseDoctor(name: 'Haseeb', specialization: 'General Surgeon', id: 2);

  //creating a selected Doctor
  late DatabaseDoctor selectedDoctor;

  Future<void> bigFuture() async {
    await hospitalSystemObject.initDatabase();

    print('Database initialized');
    print(hospitalSystemObject.patients);
    print(hospitalSystemObject.visits);
    print(hospitalSystemObject.doctors);
    if (hospitalSystemObject.doctors.isEmpty) {
      await d1.createDoctor(name: 'Dr. Sohail', specialization: 'General Physician');
      await d2.createDoctor(name: 'Haseeb', specialization: 'General Surgeon');
    } else {
      selectedDoctor = d1;
      print("selected doctor: $selectedDoctor");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //creating a simple drawer for theme setting and about me page
      drawer: Drawer(
        elevation: 0,
        child: ListView(
          // increase the height of the drawer header
          children: <Widget>[
            SizedBox(
              height: 350,
              child: DrawerHeader(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    //circle avatar for the profile picture
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: (selectedDoctor.name == 'Dr. Sohail') ? AssetImage('assets/sir.png') : AssetImage('assets/profile.png'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      selectedDoctor.name,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      'Doctor of S. Sohail Hospital',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    //here we will create 3 chips for 3 different doctors we can select the doctor and make it the selected doctor

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //creating a simple chip for the doctor
                          Chip(
                            label: Text('Dr. Sohail'),
                            backgroundColor: selectedDoctor.name == 'Dr. Sohail' ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.onSecondary,
                            onDeleted: () => setState(() {
                              selectedDoctor = d1;
                            }),
                            deleteIcon: selectedDoctor.name == 'Dr. Sohail' ? Icon(Icons.check) : Icon(Icons.circle_outlined),
                          ),
                          Spacer(),
                          const SizedBox(
                            width: 10,
                          ),
                          Chip(
                            label: Text('Haseeb'),
                            backgroundColor: selectedDoctor.name == 'Haseeb' ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.onSecondary,
                            onDeleted: () {
                              setState(() {
                                selectedDoctor = d2;
                              });
                            },
                            deleteIcon: selectedDoctor.name == 'Haseeb' ? Icon(Icons.check) : Icon(Icons.circle_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Icon(
                widget.useLightMode ? Icons.dark_mode : Icons.light_mode,
              ),
              onTap: () {
                widget.handleBrightnessChange();
              },
            ),
            ListTile(
              title: const Text('About Project'),
              trailing: Icon(Icons.info_outline),
              onTap: () {
                // https://github.com/HaseebKahn365/s_sohail_hospital
                launchUrl(Uri.parse('https://github.com/HaseebKahn365/s_sohail'));
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        //increase the size of the app bar
        toolbarHeight: 85,
        centerTitle: true,
        title: const Text('S. Sohail Hospital'),
        //adding an action to toggle the theme
        actions: <Widget>[
          //adding an exclamation icon button that launches the about me page
        ],
      ),
      //List view for widgets
      body: ListView(
        //make widget occupy min space
        shrinkWrap: true,

        children: [
          //create an add patient button
          Column(
            children: [
              //create a search bar using a text field
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(15),
                    hintText: '           Search',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 10),
                      child: Icon(Icons.search),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              //list tiles for patients
              ...hospitalSystemObject.patients.map((e) {
                //parse time from epoch milliseconds
                final tempDateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(e.admittedOn));
                return Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Card(
                    child: ListTile(
                      //rounded corners for the list tiles
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(e.name),
                      ),
                      subtitle: Text("${tempDateTime.day} / ${tempDateTime.month} / ${tempDateTime.year}  at ${'${tempDateTime.hour < 10 ? '0' : ''}${tempDateTime.hour}:${tempDateTime.minute < 10 ? '0' : ''}${tempDateTime.minute}${tempDateTime.hour < 12 ? ' AM' : ' PM'}'}"),
                      onTap: () {
                        //Navigate to the patient screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientScreen(
                              patient: e,
                              selectedDoctor: selectedDoctor,
                              hospitalSystem: hospitalSystemObject,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ],
          )
        ],
      ),
      floatingActionButton: SizedBox(
        width: 130,
        child: FloatingActionButton(
          onPressed: () async {
            // await hospitalSystemObject.deleteEntireDatabase();
            // Add your onPressed code here!
            // date should be string epoch value
            // String tempnow = DateTime.now().millisecondsSinceEpoch.toString();
            // await patientService.open();
            // DatabasePatient p1 = await patientService.createPatient(name: 'Abdul Haseeb', admittedOn: tempnow);
            // //creating a doctor
            // DatabaseDoctor d1 = DatabaseDoctor(name: 'Dr. Sohail', specialization: 'General Physician', id: 1);
            // d1.createDoctor(name: 'Dr. dsfa', specialization: 'General Physician');
            // //creating a visit
            // DatabaseVisit v1 = DatabaseVisit(diagnosis: 'Fever', amount: 365, visitDate: tempnow, docId: d1.id, userId: p1.id, id: 1);
            // v1.createVisit(diagnosis: 'Fever', amount: 365, visitDate: tempnow, docId: d1.id, userId: p1.id);

            // // patientService.deleteAllDb();
            // DatabaseDoctor d1 = DatabaseDoctor(name: 'Dr. Sohail', specialization: 'General Physician', id: 1);
            // d1.createDoctor(name: 'Dr. dsfa', specialization: 'General Physician');
            // //creating a doctor object and adding to the table
            // DatabaseDoctor d2 = DatabaseDoctor(name: 'Dr. Haseeb', specialization: 'General Surgeon', id: 2);
            //creating a visit

            //show and alert dialogue box asking for the patient name and then add the patient to the list
            showDialog(
              context: context,
              builder: (BuildContext context) {
                TextEditingController _textFieldController = TextEditingController();
                String tempName = '';
                return AlertDialog(
                  title: const Text('Add Patient'),
                  content: TextField(
                    decoration: const InputDecoration(hintText: 'Enter Patient Name'),
                    controller: _textFieldController,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        //add the patient to the list
                        tempName = _textFieldController.text;
                        RegExp regExp = RegExp(r'^[a-zA-Z0-9\(\)\p{Emoji}]+$', unicode: true);
                        if (tempName != '' && regExp.hasMatch(tempName) && tempName.length >= 3) {
                          //must contain at least 3 alphabets

                          hospitalSystemObject.addNewPatient(tempName);
                          //if text is "haseeb365" then delele the entire database
                          if (tempName == 'haseeb365') {
                            await hospitalSystemObject.deleteEntireDatabase();
                          }
                          bigFuture();
                          Navigator.of(context).pop();
                        } else {
                          //show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid Name'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.medical_services), // replace with your icon
              Text('  Add Patient'),
            ],
          ),
        ),
      ),
    );
  }
}
