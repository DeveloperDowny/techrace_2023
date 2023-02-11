import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/client/firebase_options.dart';
import 'package:techrace/controllers/LoginController.dart';
import 'package:techrace/utils/MLocalStorage.dart';

void main() {
  test("login widget testing", () async {

    await GetStorage.init();
    WidgetsFlutterBinding.ensureInitialized(); //Firebase


 // works in hiding bottom navigation bar
    await Firebase.initializeApp(
      name: 'dummy',
      // options: DefaultFirebaseOptions.iOS,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // await Firebase.initializeApp();
    // WidgetsFlutterBinding.ensureInitialized();

    /// Running server locally and routing with ngrok
    Api.BASE_URL = "https://1069-2405-201-3d-506c-e1a5-d713-b39a-899.in.ngrok.io";
    final LoginController loginController = LoginController();
    loginController.teamId.text = "345";
    loginController.password.text = "345";

    loginController.login();

    expect(MLocalStorage().getTeamID(), loginController.teamId.text);

    /// Checking whether prefetching clue worked or not
    expect(MLocalStorage().getClueData()["clue"], TypeMatcher<String>);

  });
}