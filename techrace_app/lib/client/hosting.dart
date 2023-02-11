// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class Data {
//   static Map? locData;
// }

// var startDateTime = ValueNotifier('');
// //iso 8601 formate: YYYY-MM-DDTHH:MM:SSZ
// ValueNotifier<DateTime> time =
//     ValueNotifier(DateTime.parse("0000-00-00T00:00:00"));
// bool dataFetched = false;

// Future<void> fetchLocations() async {
//   String link = "https://dummy.web.app/location.json";
//   final response = await http.get(Uri.parse(link));
//   if (response.statusCode == 200) {
//     Map result = json.decode(response.body);
//     Data.locData = result;
//     dataFetched = true;
//   } else {
//     dataFetched = false;
//     throw Exception('Failed to load locations');
//   }

//   // print(Data.locData?['names']);
//   // print(Data.locData?['locations']);
// }

// Future<void> fetchTime() async {
//   String link = "https://dummy.web.app/time.json";
//   final response = await http.get(Uri.parse(link));
//   if (response.statusCode == 200) {
//     Map result = json.decode(response.body);
//     // Data.locData = result;
//     // print(result);
//     // print(result['startTime']);
//     // startDateTime.value = result['startTime'];
//     // print(DateTime.parse(startDateTime.value));
//     // var time = DateTime.now();
//     time.value = DateTime.parse(result['startTime']);
//     // var start = DateTime.parse(startDateTime.value);
//     // print("dtest: ${time.value}");
//     // //
//     // print("time dtest: $time");
//     // print("start dtest: $start");
//     // var diff = time.difference(start);
//     // print("dtest: ${diff}");
//     // print("dtest hrs: ${diff.inHours}");
//     // print("dtest mins: ${diff.inMinutes}");
//     // print("dtest secs: ${diff.inSeconds}");
//     // print(object)
//     // print(DateTime.now());
//     // dataFetched = true;
//   } else {
//     // dataFetched = false;
//     throw Exception('Failed to load locations');
//   }

//   // print(Data.locData?['names']);
//   // print(Data.locData?['locations']);
// }
