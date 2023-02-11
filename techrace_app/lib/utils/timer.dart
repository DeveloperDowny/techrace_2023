import 'dart:async';

//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:techrace/client/hosting.dart';
// import 'package:techrace/controllers/HomeController.dart';
// import 'package:techrace/utils/TimeStream.dart';

//up count timerUp
var secs = ValueNotifier(0);
var mins = ValueNotifier(0);
var hrs = ValueNotifier(0);
DateTime time = DateTime.now();

class TimerUp extends StatefulWidget {
  const TimerUp({super.key});

  @override
  State<TimerUp> createState() => _TimerUpState();
}

class _TimerUpState extends State<TimerUp> {
  // ValueNotifier<DateTime> time = ValueNotifier(DateTime.parse("0000-00-00T00:00:00"));
  
  Timer timer = Timer.periodic(const Duration(seconds: 1), (Timer _) {
    // print('timer test');
    
    DateTime now = DateTime.now();
    // print('time now is $now');

    var difference = now.difference(time);
    //print("time difference is $difference");
    //print("time difference is ${difference.inSeconds}");
    if (difference.inSeconds < 0) {
      difference = const Duration(seconds: 0);
    }
    secs.value = (difference.inSeconds % 60);
    mins.value = (difference.inMinutes % 60);
    hrs.value = difference.inHours;

    //1674966600000
  });

  // @override
  // void initState() {
  //   super.initState();
  //   //TimeStream();
  // }

  // @override
  // void dispose() {
  //   timer.cancel();
  //   super.dispose();
  //   //TimeStream().sub1.cancel();
    
  // }

  @override
  Widget build(BuildContext context) {
    // timestream.listen((DatabaseEvent event) {
    //   //this is where you get the start time
    //   time = DateTime.fromMillisecondsSinceEpoch(event.snapshot.value as int);
    //   // print("time is ${time.value}");
    // });

    return ValueListenableBuilder(
        valueListenable: secs,
        builder: (context, value, child) {
          return Row(
            children: [
              (hrs.value > 0)
                  ? ((hrs.value < 10)
                      ? Text("0${hrs.value} : ")
                      : Text("${hrs.value} : "))
                  : const SizedBox(),
              (hrs.value > 0 || mins.value > 0)
                  ? ((mins.value < 10)
                      ? Text("0${mins.value} : ")
                      : Text("${mins.value} : "))
                  : const SizedBox(),
              (hrs.value == 0 && mins.value == 0 && secs.value == 0)
                  ? const SizedBox(
                      height: 10,
                      width: 10,
                    )
                  : (secs.value < 10)
                      ? Text("0${secs.value}")
                      : Text("${secs.value}"),
            ],
          );
        });
  }
}
