// import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_beacon/flutter_beacon.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:techracev/gamevalidate.dart';
import 'package:techracev/home.dart';
import 'package:techracev/utils/timestream.dart';
import 'package:techracev/utils/datetime.dart';
import 'package:techracev/utils/perms.dart';
import 'firebase_options.dart';
import 'package:get_storage/get_storage.dart';

import 'login.dart';
//global vars
int clueNo =
    0; //to be used to update the rtdb for every team whos beacon is detected
String fbChild = "dummy_teams";
//global vars

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutterBeacon.initializeScanning;
  await checkPerms();
  try {
    await getDateSetting();
    //await fetchTime();
  } catch (e) {
    //debugPrint("Error: $e");
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    //debugPrint("Error: $e");
  }
  await GetStorage.init();

  runApp(const Pilot());
}

class Pilot extends StatefulWidget {
  const Pilot({super.key});

  @override
  State<Pilot> createState() => _PilotState();
}

class _PilotState extends State<Pilot> {
  int password = 0;

  @override
  void initState() {
    super.initState();
    final box = GetStorage();

    clueNo = box.read("clueNo") ?? 0;
    print("clueNo: $clueNo");
    TimeStream();
  }

  @override
  void dispose() {
    super.dispose();
    TimeStream().sub1.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // if(nearby)
    return GetMaterialApp(
      theme: dark,
      title: 'TechRaceV',
      home: const Home(),
    );
  }
}

ThemeData dark = ThemeData(
  backgroundColor: Colors.white,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Color(int.parse("0xFF0B0E11")),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Color(int.parse("0xFF66fcf1")),
    unselectedItemColor: Colors.white,
    backgroundColor: Color(int.parse("0xFF0B0E11")),
  ),
  scaffoldBackgroundColor: Color(int.parse("0xFF0B0E11")),
  inputDecorationTheme: InputDecorationTheme(
    //fillColor: Colors.white,
    //filled: true,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Colors.white,
      ),
    ),
  ),
  //text button theme
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
          Color.fromARGB(255, 110, 105, 105).withOpacity(0.2)),
    ),
  ),
  
);
