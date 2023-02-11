import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/gamesheet.dart';

// import 'package:techrace/client/location.dart';
import 'package:techrace/islandanim.dart';
import 'package:techrace/map.dart';
import 'package:techrace/pages/login_screen.dart';
import 'package:techrace/utils/GenericUtil.dart';
import 'package:techrace/utils/MStyles.dart';
import 'package:techrace/utils/locmeter.dart';
import 'package:techrace/utils/notify_services.dart';
import 'package:techrace/utils/sidebar.dart';

import 'dart:io';

//isTracking = false then map will not follow user
//isTracking = true then map will adjust to center user
ValueNotifier<bool> isTracking = ValueNotifier(false);
GlobalKey<MapWidgetState> mapKey = GlobalKey();
GlobalKey<ConfettiState> confettiKey = GlobalKey();
late AppLifecycleState appState;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

bool sendNotification() {
  // if (Platform.isIOS) {
  //   // return (appState == AppLifecycleState.inactive || appState == AppLifecycleState.paused || appState == AppLifecycleState.detached);
  //   return true;
  // }
  if (Platform.isIOS) {
    return (appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.inactive ||
        appState == AppLifecycleState.detached);
  }
  return (appState == AppLifecycleState.paused);
}

// not working// you don't need this
class HomeState extends State<Home> with WidgetsBindingObserver {
  //check for this
// class HomeState extends State<Home> {
  //check for this
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   print("i am herer");
  //   if (state == AppLifecycleState.resumed) {
  //   print("resumed");
  //   } else if (state == AppLifecycleState.inactive) {
  //     print("inc");
  //   } else if (state == AppLifecycleState.paused) {
  //     print("pasue");
  //   } else if (state == AppLifecycleState.detached) {
  //     print("detached");
  //   }
  // }

  final HomeController homeController = Get.put(HomeController());

  //applifecyclestate
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //print('initState');
    appState = WidgetsBinding.instance.lifecycleState as AppLifecycleState;
    //print("appState: $appState");
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print('didChangeDependencies');
  // }
  // @override
  // void setState(fn) {
  //   super.setState(fn);
  //   print('setState');
  // }
  // @override
  // void deactivate() {
  //   super.deactivate();
  //   print('deactive');
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print("Change in app lifecycle");
    // if (state == AppLifecycleState.resumed) {
    // print("LifeCycle: resumed");

    // } else if (state == AppLifecycleState.inactive) {
    //   print("LifeCycle: inactive");
    // } else if (state == AppLifecycleState.paused) {
    //   print("LifeCycle: paused");
    // } else if (state == AppLifecycleState.detached) {
    //   print("LifeCycle: detached");
    // }
    //print("appState:(changed) $appState");
    appState = state;
  }

  @override
  void dispose() {
    // homeController.homeModel.sub1.cancel(); //technically is not required
    Get.delete<HomeController>();
    homeController.dispose(); //what about the reg screen wala part
    print(homeController.isClosed); //it is not closed
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //    elevation: 0,
      //    ),
      // appBar: AppBar(
      //   systemOverlayStyle: SystemUiOverlayStyle(
      //     systemNavigationBarColor: Colors.blue, // Navigation bar
      //     statusBarColor: Colors.pink, // Status bar
      //     status
      //   ),
      // ),
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          MapWidget(
            key: mapKey,
          ),

          // Positioned.fill(
          //   child: Align(
          //     alignment: Alignment.topCenter,
          //     child: IconButton(
          //       icon: Icon(Icons.confirmation_number),
          //       onPressed: (() => showCOnfetti()),
          //     ),
          //   ),
          // ),

          Positioned(
              // 8, 20, 0, 0
              top: 50,
              left: 14,
              child: CircleAvatar(
                backgroundColor: Color(0xcc2e92da),
                radius: 20,
                child: IconButton(
                    // color: Colors.blue,

                    onPressed: () {
                      GenericUtil.logout();
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 15,
                    )),
              )),
          Positioned(top: 50, right: 14, child: LocationButton()),
          Positioned.fill(
            // top: 82,
            top: 100,
            child: Align(
              alignment: Alignment.topCenter,
              // child: Obx(() => DynamicIslandAnimated(textToNotify: homeController.is_freezed.value.toString())),
              child: DynamicIslandAnimated(),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  SideBar(), // don't have two widgets, ussi widget ko animate karna hai
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: LocationMeter(),
            ),
          ),
          GameSheet(),
          //  here
          //   Obx(() => !homeController.isLoading.value ? SizedBox() : TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 500 * 10),                     builder:
          //       (BuildContext context, Object? value, Widget? child) {
          //     return Positioned(
          //       top: double.parse(value.toString()),
          //         child: Container(
          //           color: MStyles.darkBgColor.withOpacity(
          //               double.parse( value.toString())
          //             // 0.5
          //           ),
          //           child: Center(child: CircularProgressIndicator()),
          //         ));
          //   }))

          // Obx(() =>
          // !homeController.isLoading.value ? SizedBox() : Align(
          //
          //   // top: 10,
          //
          //     alignment: Alignment.topCenter,
          //     child: IntrinsicHeight(child: Container(
          //       margin: EdgeInsets.only(top: 64),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.all(Radius.circular(10)),
          //         color: MStyles.pColor,), width: ScreenUtil().screenWidth * 0.9,
          //
          //       // 0.5
          //       child: Center(child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(homeController.loadingTextToShow, style: MStyles.mTextStyle),
          //           Container(
          //               height: 50.h,
          //               width: 50.h,
          //               padding: EdgeInsets.all(8),
          //               margin: EdgeInsets.all(8),
          //               child: CircularProgressIndicator(color: Colors.white,)),
          //         ],
          //       ),),),)))
          Padding(
            padding: const EdgeInsets.only(top: 128.0),
            child: Confetti(key: confettiKey),
          ),
        ],
      ),
      // floatingActionButton: LocationButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}

class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => ConfettiState();
}

class ConfettiState extends State<Confetti> {
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 1),
  );
  void showConfetti() {
    //print("confetti");
    _confettiController.play();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   NotificationService.showNotification(
  //       FlutterLocalNotificationsPlugin(), "Kudos!", "You just validated");
  // }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // const Confetti({
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        // don't specify a direction, blast randomly
        shouldLoop: false,
        // start again as soon as the animation is finished
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ], // manually specify the colors to be used
      ),
    );
  }
}

class LocationButton extends StatelessWidget {
  const LocationButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isTracking,
      builder: (context, value, child) {
        return InkWell(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: (isTracking.value)
                  ? Colors.grey.withOpacity(0.5)
                  : Colors.blueGrey.withOpacity(0.5),
            ),
            child: Icon(Icons.my_location_rounded,
                color: value ? Colors.red : Colors.blue),
          ),
          onTap: () {
            // print("isTracking.value: ${isTracking.value}");
            if (!isTracking.value) {
              currentLocation();
            }
          },
          onLongPress: () {
            isTracking.value = !isTracking.value;
            if (isTracking.value) {
              positionStream.resume();
            } else {
              positionStream.pause();
              currentLocation();
            }
          },
        );
      },
    );
  }
}
