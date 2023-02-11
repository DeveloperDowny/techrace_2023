import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/main.dart';
import 'package:techrace/utils/MLocalStorage.dart';

import 'package:techrace/utils/timer.dart';

class TimeStream {
  late DatabaseReference ref;
  final HomeController homeController = Get.find<HomeController>();
  String teamId = MLocalStorage().getTeamID();
  TimeStream() {
    // ref = FirebaseDatabase.instance.ref("/start_datetime");

    // ref = FirebaseDatabase.instance.ref("/dummy_teams/$teamId/prev_clue_solved_timestamp");
    // stream = ref.onValue;
    // sub1 = stream.listen((DatabaseEvent event) {
    //   // print(event.snapshot.value);
    //   time = DateTime.parse(event.snapshot.value as String);
    // });

    // print('homeController.clueNo.value: ${homeController.clueNo.value}');
    // if (homeController.clueNo.value == 1) {
    //   ref = FirebaseDatabase.instance.ref("/start_datetime");
    //   print('start_datetime');
    //   stream = ref.onValue;
    //   sub1 = stream.listen((DatabaseEvent event) {
    //     // print(event.snapshot.value);
    //     time = DateTime.parse(event.snapshot.value as String);
    //   });
    //   sub1.resume();
    // } else if (homeController.clueNo.value > 1) {
    //   String teamId = MLocalStorage().getTeamID();

    //   ref = FirebaseDatabase.instance
    //       .ref("/dummy_teams/$teamId/prev_clue_solved_timestamp");
    //   print('prev_clue_solved_timestamp');
    //   stream = ref.onValue;
    //   sub1 = stream.listen((DatabaseEvent event) {
    //     // print(event.snapshot.value);
    //     time = DateTime.parse(event.snapshot.value as String);
    //   });
    //   sub1.resume();
    // }

    // sub1 = ref.onValue.listen((DatabaseEvent event) {
    //   // print(event.snapshot.value);
    //   print("homeController.clueNo.value: ${homeController.clueNo.value}");
    //   if (homeController.clueNo.value == 1) {
    //     time = DateTime.parse(MLocalStorage().getStartDateTime());
    //     print("time: $time");
    //   } else if (homeController.clueNo.value > 1) {
    //     time = DateTime.parse(event.snapshot.value as String);
    //   } else {
    //     print("else statement");
    //     time = DateTime.now();
    //   }
    // });

    // //without stream
    // ref = FirebaseDatabase.instance
    //     .ref("dummy_teams/$teamId/prev_clue_solved_timestamp");
    // if (homeController.clueNo.value == 1) {
    //   time = DateTime.parse(MLocalStorage().getStartDateTime());
    // } else if (homeController.clueNo.value > 1) {
    //   // ref.once().then((DataSnapshot snapshot) {
    //   //   time = DateTime.parse(snapshot.value as String);
    //   // });
    //   final timeRef = ref.once();
    //   // timeRef.then((DataSnapshot snapshot) {
    //   //   time = DateTime.parse(snapshot.value as String);
    //   // });
    //   // ref.get().then((DataSnapshot snapshot) {
    //   //   print('snapshot.value: ${snapshot.value}');
    //   //   time = DateTime.parse(snapshot.value as String);
    //   // });
    // }
  }
  Future<void> updateTime() async {
    HomeController homeController = Get.find<HomeController>();
    ref = FirebaseDatabase.instance.ref("$fbTeam/$teamId"); //team string
    //print('homeController.clueNo.value: ${homeController.clueNo.value}');
    if (homeController.clueNo.value == 1) {
      time = DateTime.parse(MLocalStorage().getStartDateTime());
      homeController.prevClueSolvedTimeStamp.value = MLocalStorage().getStartDateTime();
    } else if (homeController.clueNo.value > 1) {
      // ref.once().then((DataSnapshot snapshot) {
      //   time = DateTime.parse(snapshot.value as String);
      // });

      final timeRef = await ref.child('/prev_clue_solved_timestamp').once();
      // timeRef.then((DataSnapshot snapshot) {
      //   time = DateTime.parse(snapshot.value as String);
      // });

      time = DateTime.parse(timeRef.snapshot.value as String);
      homeController.prevClueSolvedTimeStamp.value = timeRef.snapshot.value as String;
      
      //print('time: $time');
      // ref.get().then((DataSnapshot snapshot) {
      //   print('snapshot.value: ${snapshot.value}');
      //   time = DateTime.parse(snapshot.value as String);
      // });
    }
  }
}
