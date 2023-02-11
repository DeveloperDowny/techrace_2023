import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:techrace/utils/MLocalStorage.dart';

class WaitingModel {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late String tid;
  late DatabaseReference ref;
  late Stream<DatabaseEvent> stream;

  late StreamSubscription<DatabaseEvent> sub1;

  WaitingModel(Rx<int> timeLeft) {
    // tid = MLocalStorage().getTeamID();
    // ref = FirebaseDatabase.instance.ref("/");
    // ref = FirebaseDatabase.instance.ref("/time_to_start");
    ref = FirebaseDatabase.instance.ref("/start_datetime");

    // Get the Stream
    // Stream<DatabaseEvent> stream = ref.onValue; //current pe hota hai
    stream = ref.onValue; //current pe hota hai
    // ref.onChildChanged
// /tid/clue_no

    // Subscribe to the stream!
    sub1 = stream.listen((DatabaseEvent event) {
      // int newTimeLeft;
      // final newDateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(event.snapshot
      //     .value
      //     .toString()));

      final newDateTime = DateTime.parse(event.snapshot.value.toString());

      MLocalStorage().writeStartDateTime(event.snapshot.value.toString());

      final newTimeLeft = newDateTime.difference(DateTime.now()).inSeconds;
      timeLeft.value = newTimeLeft;
    });
  }
}
