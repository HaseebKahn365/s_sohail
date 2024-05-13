// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, must_be_immutable

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:s_sohail/classes_and_vars/buisiness_logic_and_classes.dart';
import 'package:s_sohail/screens/database_view.dart';
import 'package:s_sohail/screens/patient_screen.dart';
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
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isFirstTime = false;
      });
    });
  }

  void refresher() {
    setState(() {});
  }

  DatabaseDoctor d1 = DatabaseDoctor(name: 'Dr. Sohail', specialization: 'General Physician', id: 1);
  DatabaseDoctor d2 = DatabaseDoctor(name: 'Haseeb', specialization: 'General Surgeon', id: 2);

  //creating a selected Doctor
  DatabaseDoctor selectedDoctor = DatabaseDoctor(name: 'Dr. Sohail', specialization: 'General Physician', id: 1);

  //list for special Doctors

  Future<void> bigFuture() async {
    await hospitalSystemObject.initDatabase();

    print('Database initialized');
    print(hospitalSystemObject.patients);
    print(hospitalSystemObject.visits);
    print(hospitalSystemObject.doctors);
    if (hospitalSystemObject.doctors.isEmpty) {
      await d1.createDoctor(name: 'Dr. Sohail', specialization: 'General Physician');
      await d2.createDoctor(name: 'Haseeb', specialization: 'General Surgeon');
      selectedDoctor = d1;
    } else {
      selectedDoctor = d1;
      print("selected doctor: $selectedDoctor");
    }
    displayedPatients = hospitalSystemObject.patients;
    setState(() {});
  }

  List<DatabasePatient> displayedPatients = [];

  void getNewPatients(String searchTerm) {
    if (searchTerm == '') {
      displayedPatients = hospitalSystemObject.patients;
    } else {
      displayedPatients = hospitalSystemObject.patients.where((element) => element.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();
    }
    setState(() {});
  }

  TextEditingController searchTermController = TextEditingController();
  bool isFirstTime = true;

  @override
  Widget build(BuildContext context) {
    return
        //if first time display a circular progress indicator with 2 seconds delay
        (isFirstTime)
            ? Scaffold(
                body: Center(
                  child: SizedBox(
                      width: 400,
                      height: 130,
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'This App is too fast...',
                            style: TextStyle(fontSize: 17),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'slowed down by Haseeb ',
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(
                                '😉',
                                style: TextStyle(fontSize: 21, color: Colors.red),
                              ),
                            ],
                          )
                        ],
                      )),
                ),
              )
            : Scaffold(
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
                        trailing: Icon(
                            //Clipboard Text Ltr
                            FluentIcons.clipboard_text_ltr_24_regular),
                        onTap: () {
                          // https://github.com/HaseebKahn365/s_sohail_hospital
                          launchUrl(Uri.parse('https://github.com/HaseebKahn365/s_sohail'));
                        },
                      ),

                      //here we add another list tile for database table view screen, we will navigate there by material push route
                      ListTile(
                        title: const Text('Database Table View'),
                        trailing: Icon(Icons.table_view),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DatabaseTableView(
                                hospitalSystem: hospitalSystemObject,
                              ),
                            ),
                          );
                        },
                      )
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
                    //add a refresh button
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        refresher();
                      },
                    ),
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
                            controller: searchTermController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(15),
                              hintText: '           Search',
                              //trailing clear button
                              suffixIcon: searchTermController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        searchTermController.clear();
                                        getNewPatients('');
                                      },
                                    )
                                  : null,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 10),
                                child: Icon(Icons.search),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            onChanged: (value) {
                              getNewPatients(value);
                            },
                          ),
                        ),
                        //list tiles for patients
                        //displayed patients are only those that are affected by the search term
                        ...displayedPatients.map((e) {
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

                                //add a circle avatar for picture of the patient we will use the patient id as int num =(patientId ~/ 5)+1 to get the proper image from asset
                                //picture will be assets/$num.jpg
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage('assets/${(e.id % 5) + 1}.jpg'),
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
                          ).animate(
                            effects: [
                              //animate the list tiles
                              FadeEffect(
                                duration: Duration(milliseconds: 500),
                                delay: Duration(milliseconds: 100 * displayedPatients.indexOf(e)),
                              )
                            ],
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
                                  if (tempName != '' && tempName.length >= 2) {
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
