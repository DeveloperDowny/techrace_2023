import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/pages/login_screen.dart';
import 'package:techrace/pages/registration_screen.dart';
import 'package:techrace/client/datetime.dart';
import 'package:techrace/home.dart';
import 'package:techrace/pages/waiting_screen.dart';
import 'package:techrace/utils/MLocalStorage.dart';
import 'package:techrace/utils/notify_services.dart';
// import 'package:techrace/utils/locmeter.dart';
import 'client/hosting.dart';
import 'client/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'client/firebase_options.dart';

late FlutterLocalNotificationsPlugin globalNotification;
String fbTeam = 'dummy_teams'; //change this according to firebase rtdb
Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized(); //Firebase

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar //working
    statusBarIconBrightness: Brightness.light, // status bar icons' color
    systemNavigationBarColor: Colors
        .transparent, // bottom navigation bar to be transparent //not working
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]); // works in hiding bottom navigation bar
  await Firebase.initializeApp(
    name: 'dummy',
    // options: DefaultFirebaseOptions.iOS,
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// await Firebase.initializeApp(
  ///   options: DefaultFirebaseOptions.currentPlatform,
  /// );

  //check location permission and enable location service
  await locateUser();
  await checkBluetoothPerms();
  //hosting service - fetch data
  // await fetchLocations();
  //runApp(const HomeTest());
  //get starttime from server
  //check if android
  if (Platform.isAndroid) {
    await getDateSetting();
  }
  //await getDateSetting();
  // await fetchTime();

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // do here
  await setBaseUrl();
  //notification service
  // display notification permission -- only possible when notification is triggered
  // solution to this(implemented)
  // as soon as user logs in, display a welcome notification so that permission is requested
  globalNotification = FlutterLocalNotificationsPlugin();
  await NotificationService.initialize(globalNotification);

  //audio setup
  if (Platform.isIOS) {
    const AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: [
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.mixWithOthers,
        ],
      ),
    );
    // NEEDED THIS audioContext or iPhone volume didn't work only BGM I could hardly hear
    AudioPlayer.global.setGlobalAudioContext(audioContext);
  }
  //audio setup
  runApp(MyApp());
}

Future<void> setBaseUrl() async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("base_url");
  final player1ref = await ref.once();
  MLocalStorage().setBaseUrl(player1ref.snapshot.value as String);
  Api.BASE_URL = player1ref.snapshot.value as String;
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // {
  final tid = MLocalStorage().getTeamID();
  // final tid = MLocalStorage.tid; //doesnt work

// }

  @override

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      //don't change this
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TechRace',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            colorScheme: const ColorScheme.dark(primary: Color(0xFF2E92DA)
                // primaryContainer: Color(0xFF303031), //button
                // tertiary: Color(0xFF000000),
                // tertiaryContainer: Color(0xFF000000),
                // background: Color(0xFFFFFF),
                // onBackground: Colors.black,
                // surface: Color(0xFF000000),
                // onSurface: Color(0xFF000000)

                // t: Color(0xFF000000),

                ),
            // scaffoldBackgroundColor: Color(0xff000512),
            scaffoldBackgroundColor: const Color(0xff000512), //0xff121827
          ),
          home: child,
        );
      },
      // child: const MyHomePage(title: 'First Method'),
      // child: RegistrationScreen(teamId: "B38",),
      // child: LoginScreen(), //a2. add direct nav here
      child: tid == "-999"
          ? LoginScreen()
          : RegistrationScreen(teamId: tid), //a2. add direct nav here
      // child: WaitingScreen() //done testing this
      // child: WaitingScreen() //done testing this
    );
  }
}
