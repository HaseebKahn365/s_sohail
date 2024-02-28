// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SSohailHospital());
}

class SSohailHospital extends StatefulWidget {
  const SSohailHospital({Key? key}) : super(key: key);

  @override
  State<SSohailHospital> createState() => _SSohailHospitalState();
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

class _SSohailHospitalState extends State<SSohailHospital> {
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

  const HomeScreen({
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
      appBar: AppBar(
        title: const Text('S. Sohail Hospital'),
        //adding an action to toggle the theme
        actions: <Widget>[
          //adding an exclamation icon button that launches the about me page
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // https://github.com/HaseebKahn365/s_sohail_hospital
              launchUrl(Uri.parse('https://github.com/HaseebKahn365/s_sohail_hospital'));
            },
          ),
          IconButton(
            icon: Icon(widget.useLightMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.handleBrightnessChange,
          ),
        ],
      ),
      body: Center(
        child: Text("Hello World"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
