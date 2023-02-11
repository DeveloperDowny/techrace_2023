import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/home.dart';
import 'package:techrace/main.dart';
import 'package:techrace/utils/GenericUtil.dart';
import 'package:techrace/pages/waiting_screen.dart';
import 'package:techrace/utils/MLocalStorage.dart';
import 'package:techrace/utils/notify_services.dart';
import 'package:techrace/utils/time.dart';
import 'package:techrace/utils/locmeter.dart';

import '../utils/GenericUtil.dart';

class HomeModel {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late String tid;
  late DatabaseReference ref;
  late Stream<DatabaseEvent> stream;
  late DatabaseReference dbRef;
  late Stream<DatabaseEvent> teamStream;
  late StreamSubscription<DatabaseEvent> sub1;
  late HomeController homeController;

  // final HomeController homeController = Get.find<HomeController>();

  HomeModel(HomeController mhomeController) {
    homeController = mhomeController;
    // tid = MLocalStorage().getTeamID();
    // ref = FirebaseDatabase.instance.ref("/");
    // ref = FirebaseDatabase.instance.ref("/time_to_start");
    //
    // // Get the Stream
    // // Stream<DatabaseEvent> stream = ref.onValue; //current pe hota hai
    // stream = ref.onValue; //current pe hota hai
    // ref.onChildChanged
// /tid/clue_no

    // Subscribe to the stream!

    final box = GetStorage();
    final teamId = box.read('tid');
    dbRef = FirebaseDatabase.instance.ref("/$fbTeam/$teamId"); //team string
    // debugPrint("teamId: $teamId");

    initData(dbRef.once(DatabaseEventType.value));

    teamStream = dbRef.onChildChanged;

    //you need to change few things here
    // don't bulk I would say.
    sub1 = teamStream.listen((DatabaseEvent event) async {
      if (event.snapshot.key == "is_meter_off") {
        homeController.is_meter_off.value = event.snapshot.value as bool;
        if (sendNotification()) {
          NotificationService.showNotification(
              globalNotification,
              homeController.is_meter_off.value
                  ? "Your Meter Has Been Turned Off!"
                  : "Your Meter Has Been Turned On Again!",
              "TechRace");
        }
        showStringOnDI(homeController.is_meter_off.value
            ? "Your Meter Has Been Turned Off!"
            : "Your Meter Has Been Turned On Again!");
        // if (homeController.is_meter_off.value) {
        //
        // }
      } else if (event.snapshot.key == "is_freezed") {
        homeController.is_freezed.value = event.snapshot.value as bool;
        showStringOnDI(homeController.is_freezed.value
            ? "You Have Been Freezed!"
            : "You Have Been Unfreezed!");
        //.toString() == "true";
        // homeController.animationController.reverse();
        // showStringOnDI();

        // animations should not be handled in contoller
      } else if (event.snapshot.key == "freezed_by") {
        homeController.freezed_by.value = event.snapshot.value as String;
      } else if (event.snapshot.key == "freezed_on") {
        homeController.freezed_on = event.snapshot.value as String;
        setReversalTimer(event.snapshot.value.toString());
      }else if (event.snapshot.key == "meter_off_on") {
        homeController.meter_off_on = event.snapshot.value as String;

      }else if (event.snapshot.key == "prev_clue_solved_timestamp") {
        homeController.prevClueSolvedTimeStamp.value = event.snapshot.value as String;

      }else if (event.snapshot.key == "invisible_on") {
        homeController.invisible_on = event.snapshot.value as String;

      } else if (event.snapshot.key == "current_clue_no") {
        
        //show confetti when clue number changes
        confettiKey.currentState?.showConfetti();

        homeController.clueNo.value = event.snapshot.value as int;
        // homeController.clueData.value = homeController.clueNo.value == 1
        //     ? MLocalStorage().getClueData()
        //     : await Api()
        //         .getClueFromCid(homeController.clueNo.value.toString());
        if (sendNotification()) {
          NotificationService.showNotification(
              globalNotification,
              "Yay! You just reached clue ${homeController.clueNo.value - 1}", "TechRace");
        }
        await TimeStream().updateTime();
        // homeController.cid = standardise karna hoga
        //keep this as it is.

        homeController.clueData.value = homeController.clueNo.value == 1
            ? MLocalStorage().getClueData()
            : await Api()
                .getClueFromCid(homeController.clueNo.value.toString());
        // await Api().getClueFromCid(homeController.clueNo.value.toString());
        // print('clue data: ${homeController.clueData}');
        // print("clue data: ${homeController.clueData['prev_clue_solved_timestamp']}");
        // homeController.prevClueSolvedTimeStamp.value = (homeController.clueNo.value == 1) ? 
        //     MLocalStorage().getStartDateTime():homeController.clueData['prev_clue_solved_timestamp'];
        //write previous clue number, lat, long to map
        //map format
        //{
        //  clue_no: {
        //  latitude: lat,
        //  longitude: lng,
        // },
        //}
        Map prevClue = {
          //previous clue map
          "lat": clueLat,
          "lng": clueLong,
        };
        final box = GetStorage();
        //
        Map markerMap = box.read('markers_stored') ?? {};
        markerMap[(homeController.clueNo.value - 1).toString()] = prevClue;
        box.write('markers_stored', markerMap);
        //add marker of previous location when player reaches new location
        mapKey.currentState?.addMarker(
            "Clue #${homeController.clueNo.value - 1}",
            clueLat,
            clueLong,
            true);

        //updating position of clue when clue number changes
        clueLat = double.parse(homeController.clueData['lat']);
        clueLong = double.parse(homeController.clueData['long']);
        homeController.clueData['hint_1'] = "-999";
        homeController.clueData['hint_2'] = "-999";
      } else if (event.snapshot.key == "balance") {
        homeController.points.value = event.snapshot.value as int;
      } else if (event.snapshot.key == "hint_1") {
        homeController.clueData['hint_1'] = event.snapshot.value as String;
      } else if (event.snapshot.key == "hint_2") {
        homeController.clueData['hint_2'] = event.snapshot.value as String;
      }
      // check this
      else if (event.snapshot.key == "hint_1_type") {
        homeController.clueData['hint_1_type'] = event.snapshot.value as String;
      } else if (event.snapshot.key == "hint_2_type") {
        homeController.clueData['hint_2_type'] = event.snapshot.value as String;
      }
      else if (event.snapshot.key == "state") {
        final state = event.snapshot.value as String;
        if (state == "Banned") {
          GenericUtil.logout();
        }
        
      }

      // run on two phones and check if works or not

      // Object? result = event.snapshot.value;
      // if (result != null) {
      //   Map data = result as Map;
      //   if (clueNo.value != data['current_clue_no']) {
      //     clueNo.value = data['current_clue_no'];
      //     clueData.value = await Api().getClueFromCid(clueNo.value.toString());
      //   }
      //   if ( points.value != data['balance']) {
      //     points.value = data['balance'];
      //   }
      //   // print(clueData.value);
      // }
      // // setState(() {});
    });
  }

  void showStringOnDI(String textToShow) {
    if (textToShow == "You Have Been Unfreezed!"){
      homeController.textToShowDI.value = textToShow;
      if (homeController.animationController.value == 0) {

        homeController.animationController.forward();
      }
      return;
    }
    homeController.animationController.value = 0;
    // homeController.textToShow.value = homeController.is_freezed.value
    //     ? "You Have Been Freezed!"
    //     : "You Have Been Unfreezed!";
    homeController.textToShowDI.value = textToShow;

    homeController.animationController.forward();
  }

//   void setReversalTimer(String newDateTimeString) {
//     homeController.animationController.value = 0;
//     homeController.textToShow.value = "You Have Been Freezed!";
// //yaha pe kahi pe bhi 60s add nahi kiya tha
//     final newDateTime = DateTime.parse(newDateTimeString.split("+")[0]);
//     final newTimeLeft = DateTime.now().difference(newDateTime).inSeconds;
//     // homeController.timeLeftForReversal.value = 999;
//     homeController.timeLeftForReversal.value = newTimeLeft;

//     homeController.reversalCountdownController = CountDownController();
//     homeController.reversalCountdownController.restart(duration: newTimeLeft);

//     homeController.animationController.forward();
//   }

  void setReversalTimer(String newDateTimeString) {
    final now = DateTime.now(); //current time
    homeController.animationController.value = 0;
    homeController.textToShowDI.value = "You Have Been Freezed!";
    final timeOfFreeze = DateTime.parse(newDateTimeString); //time of freeze
    final timeUntilrev = timeOfFreeze.add(const Duration(
        seconds:
            60)); //you can only reverse under 60 seconds // this is time left to reverse
    final timeLeft = timeUntilrev.difference(now).inSeconds;
    //print("Time: Now: $now freezed: $timeOfFreeze  timeLeft: $timeLeft");
    //if time left to reverse if less than  equal to 60 and greater than 0 then show countdown
    if (timeLeft <= 60 && timeLeft > 0) {
      homeController.timeLeftForReversal.value = timeLeft;
      //print("appState: while freezed: $appState");
      if (sendNotification()) {
        //print("appState: while freezed: $appState");
        //(ios issue is that it uses historical data to keep app in background)
        //we can't do much about it i.e. currently when the app is in background this stream is pretty much paused
        //one solution is to use flutter_background_service
        NotificationService.showNotification(
            globalNotification,
            "You've been freezed",
            "You can reverse freeze in $timeLeft seconds");
      }
      //show notification if freezed

      homeController.reversalCountdownController = CountDownController();
      homeController.reversalCountdownController.restart(duration: timeLeft);
      homeController.animationController.forward();
    }
    //if time from freeze until now is less than 450 seconds and greater than zero i.e now-timeoffreeze <450 then
    //show freeze without countdown
    else if (now.difference(timeOfFreeze).inSeconds < 450 &&
        now.difference(timeOfFreeze).inSeconds > 0) {
      homeController.animationController.forward();
    }
    //else don't show anything
    else {
      return;
    }

  }

  // make controler for clue id instead
  Future<void> initData(Future<DatabaseEvent> fdata) async {
    final data = await fdata;

    homeController.freezed_by.value = data.snapshot.child("freezed_by").value as String;
    homeController.is_meter_off.value =
        data.snapshot.child("is_meter_off").value as bool;
    homeController.points.value = data.snapshot.child("balance").value as int;
    homeController.clueNo.value =
        data.snapshot.child("current_clue_no").value as int;

    // homeController.clueData.value =
    //     await Api().getClueFromCid(homeController.clueNo.value.toString());

    homeController.clueData.value = homeController.clueNo.value == 1 //left pad right pad. uska issue
        ? MLocalStorage().getClueData()
        : await Api().getClueFromCid(homeController.clueNo.value.toString()); //use cid // isko haath laga hi mat //technically you don't need to pass anything now

    homeController.clueData.value['hint_1'] =
        data.snapshot.child('hint_1').value as String;

    homeController.clueData.value['hint_2'] =
        data.snapshot.child('hint_2').value as String;


    // type updates
    homeController.clueData.value['hint_1_type'] =
    data.snapshot.child('hint_1_type').value as String;

    homeController.clueData.value['hint_2_type'] =
    data.snapshot.child('hint_2_type').value as String;

    clueLat = double.parse(homeController.clueData['lat'] ?? '0.0');
    clueLong = double.parse(homeController.clueData['long'] ?? '0.0');
    homeController.is_freezed.value =
        data.snapshot.child("is_freezed").value as bool;
    if(homeController.clueNo.value != 1) {
      homeController.prevClueSolvedTimeStamp.value = data.snapshot.child("prev_clue_solved_timestamp").value.toString();
    }
    await TimeStream().updateTime();
    // homeController.animationController.value = 0;

    // final newDateTime = DateTime.parse(data.snapshot.child("freezed_on").value.toString().split("+")[0] );
    // final newTimeLeft = DateTime.now().difference(newDateTime).inSeconds;
    // homeController.timeLeftForReversal.value = 999;
    // homeController.timeLeftForReversal.value = newTimeLeft;
    setReversalTimer(data.snapshot.child("freezed_on").value.toString());

    // homeController.textToShow.value = homeController.is_freezed.value
    //     ? "You Have Been Freezed!"
    //     : "You Have Been Unfreezed!";
    // homeController.animationController.forward();

    homeController.freezed_on = data.snapshot.child("freezed_on").value.toString();
    homeController.meter_off_on = data.snapshot.child("meter_off_on").value.toString();
    homeController.invisible_on = data.snapshot.child("invisible_on").value.toString();
  }
}
