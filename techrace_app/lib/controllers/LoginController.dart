import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/main.dart';
import 'package:techrace/pages/registration_screen.dart';
import 'package:techrace/utils/GenericUtil.dart';
import 'package:techrace/utils/MLocalStorage.dart';
import 'package:techrace/utils/notify_services.dart';

class LoginController extends GetxController {
  // LoginController() {
  //   final tid = MLocalStorage().getTeamID();
  //   // final tid = MLocalStorage.tid; //doesnt work
  //   if ( tid  != "-999") {
  //     Get.off(() => RegistrationScreen(teamId: tid));
  //   }
  // }

  var isHidden = true.obs;
  var isLoginLoading = false.obs;
  TextEditingController teamId = TextEditingController();
  TextEditingController password = TextEditingController();

  // bool isLoginLoading;

  LoginController() {
    setBaseUrl();
  }

  Future<void> setBaseUrl() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("base_url");
    final player1ref = await ref.once();
    MLocalStorage().setBaseUrl(player1ref.snapshot.value as String);
    Api.BASE_URL = player1ref.snapshot.value as String;
  }

  login() async {
    toggleLoginLoading();
    await setBaseUrl();
    print("here set base");
    print(Api.BASE_URL);
    final currLatLng = await Geolocator.getCurrentPosition();

    final res = await Api().login(
        teamId.text, password.text, currLatLng.latitude, currLatLng.longitude);
    if (res["status"] == "1") {
      final data = GetStorage();
      data.write("tid", teamId.text);
      data.write("token", res["token"]);

      // check for this
      print("TAG: 184");
      print(MLocalStorage().getToken());
      print("MLocalStorage().getToken()");

      await prefetchClue1(res);
      // // don't do this with end point.
      // // make changes in server for clue id too

      // do this here
      // prefetchClue
      // MLocalStorage().writeClueData({
      //   "clue": res["clue_1"],
      //   "lat": res["clue_lat"],
      //   "long": res["clue_lng"]
      // });

      // data.write("key", value)
      MLocalStorage().writeStartDateTime(res["start_datetime"]);
      print(data.read("tid"));
      print(data.read("token"));
      print(MLocalStorage().getStartDateTime()); //
      print(
          "MLocalStorage().getStartDateTime()"); // what do I intend to do. Do the unlock instantly wala thingFF

      //get player names to show in the app after login from rtdb and store it in get storage for further use
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("/$fbTeam/${teamId.text}"); //team string used in login controller
      final player1ref = await ref.child("/p1").once();
      final player2ref = await ref.child("/p2").once();
      data.write('player1', player1ref.snapshot.value);
      data.write('player2', player2ref.snapshot.value);

      //creating a map of markers and writiing to get storage
      data.write('markers_stored', {}); //marker

      //last clue number --required for hiding players from leaderboard
      ref = FirebaseDatabase.instance.ref('/last_clue');
      final lastClueRef = await ref.once();
      data.write('last_clue', lastClueRef.snapshot.value);
      // print('last clue');
      // print(data.read('last_clue'));
      // final mL = MLocalStorage();
      // mL.writeTid(teamId.text);
      // mL.writeToken(res["token"]);
      //
      // print(mL.getToken());
      // print(mL.getTeamID());

      // print("here"); //working
      // final box = GetStorage();
      // print(res);
      // print(res["token"]);
      // box.write("token", res["token"]);
      // box.write("tid", teamId.text);
      //
      // //token me hi team id daal de na you won't need the team id then for calling api functions
      // print(box.read("token"));
      // print(box.read("tokenfail")); //returns null

      Get.off(() => RegistrationScreen(teamId: teamId.text));
      //show silent notification
      NotificationService.showNotification(
          globalNotification, "TechRace", "Welcome to TechRace");
    } else {
      Get.closeAllSnackbars();
      GenericUtil.fancySnack("Login Failed", res["message"]);
    }
    // login with api
    // if fail, update ui somehow

    toggleLoginLoading();
  }

  void toggleHidden() {
    isHidden.value = !isHidden.value;
  }

  Future<void> prefetchClue1(payload) async {
    final res =
        await Api().getClueFromCid(payload["current_clue_no"].toString());
    // do this here
    // prefetchClue
    MLocalStorage().writeClueData({
      "cid": res["cid"],
      "clue": res["clue"],
      "lat": res["lat"],
      "long": res["long"],
      "clue_type": res["clue_type"]
    });
  }

  void toggleLoginLoading() {
    isLoginLoading.value = !isLoginLoading.value;
  }
}
