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
import 'package:s_sohail/classes_and_vars/temp_ui_classes.dart';
import 'package:s_sohail/screens/patient_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  //using riverpod provider scope
  runApp(
    ProviderScope(
      child: SSohailHospital(),
    ),
  );
}

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

  @override
  initState() {
    super.initState();
    themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
  }

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

  List<Patient> patientList = [
    Patient(
      name: 'Abdul Haseeb',
      admittedOn: DateTime.now(),
    ),
    Patient(
      name: 'Muhammad Bilal',
      admittedOn: DateTime.now(),
    ),
    Patient(
      name: 'Muhammad Sohail',
      admittedOn: DateTime.now(),
    ),
  ];

  HomeScreen({
    Key? key,
    required this.useLightMode,
    required this.handleBrightnessChange,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
              height: 250,
              child: DrawerHeader(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    //circle avatar for the profile picture
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                    const Text(
                      'Abdul Haseeb',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      'Admin of S. Sohail Hospital',
                      style: TextStyle(
                        fontSize: 16,
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
              ...widget.patientList.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Card(
                    child: ListTile(
                      //rounded corners for the list tiles
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      title: Text(e.name),
                      subtitle: Text("${e.admittedOn.day} / ${e.admittedOn.month} / ${e.admittedOn.year}  at ${e.admittedOn.hour}:${e.admittedOn.minute} ${e.admittedOn.hour > 12 ? 'PM' : 'AM'}"),
                      onTap: () {
                        //Navigate to the patient screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientScreen(
                              patient: e,
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
          onPressed: () {
            // Add your onPressed code here!
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
