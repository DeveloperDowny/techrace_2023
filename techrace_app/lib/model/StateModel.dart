import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/main.dart';
import 'package:techrace/pages/login_screen.dart';
import 'package:techrace/utils/GameStates.dart';
import 'package:techrace/utils/MLocalStorage.dart';

class StateModel {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late String tid;
  late DatabaseReference ref;

  late StreamSubscription<DatabaseEvent> sub1;

  StateModel(Rx<String> currState) {
    tid = MLocalStorage().getTeamID();
    // ref = FirebaseDatabase.instance.ref("/");
    ref = FirebaseDatabase.instance.ref("/$fbTeam/$tid/state"); //team string

    // Get the Stream
    Stream<DatabaseEvent> stream = ref.onValue; //current pe hota hai

    // Subscribe to the stream!
    sub1 = stream.listen((DatabaseEvent event) {
      print(event.snapshot
          .child("state")
          .value
          .toString());
      print("in stream");
      currState.value = event.snapshot
          .child("state")
          .value
          .toString();


      // switch (currState.value) {
      //   case "WaitingForGameStart":
      //     {
      //       Get.off(() => LoginScreen());
      //       break;
      //     }
      //   case GameStates.WaitingForReg:
      //     {
      //       print("yaya");
      //       break;
      //     }
      //
      // }
    });
  }

    //event.snapshot.child("state").value this is the correct way
    // stream.listen((DatabaseEvent event) {
    //   final test = event.snapshot.val("state");
    //   print(test);
    //   // print((event.snapshot.value as Map )["state"]);
    //   if (event.snapshot.hasChild("state")) {
    //     print(event.snapshot.child("state").value);
    //     if (event.snapshot.child("state").value == GameStates.WaitingForGameStart.name) {
    //       currState.value = GameStates.WaitingForGameStart;
    //     }
    //   }
    //   // currState.value = GameStates.WaitingForGameStart;
    //   print('Event Type: ${event.type}'); // DatabaseEventType.value;
    //   print('Snapshot: ${event.snapshot}'); // DataSnapshot
    // });

  // }

  // final box =  MLocalStorage.box;
  // final tid = MLocalStorage().getTeamID();

  // DatabaseReference ref = FirebaseDatabase.instance.ref("test/$tid");




}

// I am expecting shit load of dumb code to get it working

