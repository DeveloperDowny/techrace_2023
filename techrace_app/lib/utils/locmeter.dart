import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/api.dart';

//user defined imports
import 'package:techrace/client/location.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:techrace/controllers/HomeController.dart';

import 'package:beacon_broadcast/beacon_broadcast.dart' as iB;
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:techrace/main.dart';
import 'package:techrace/utils/GenericUtil.dart';
import 'package:techrace/utils/MStyles.dart';
//test data
//to be receieved from database

var clueLat = 0.0;
var clueLong = 0.0;
//game distance
//speed of user
RxDouble speed = (0.0).obs;
// ValueNotifier<double> speed = ValueNotifier(0.0);

//animation (size transition for location meteter)
var animated = false;
late AnimationController meterController;
//animation

class LocationMeter extends StatefulWidget {
  const LocationMeter({super.key});

  @override
  State<LocationMeter> createState() => _LocationMeterState();
}

class _LocationMeterState extends State<LocationMeter>
    with SingleTickerProviderStateMixin {
  //animation
  late Animation<double> animation;
  //animation
  late String teamId;
  bool beaconBroadcasting = false;

  checkBeacon() async {
    bool isBroad = await flutterBeacon.isBroadcasting();
    //print("broadcasting: $isBroad");
    beaconBroadcasting = isBroad;
  }

  //ios beacon broadcast
  late StreamSubscription<Position> locationStream;
  iB.BeaconBroadcast beaconBroadcast = iB.BeaconBroadcast();

  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkBeacon();
      });
    }

    // var isBroad = await flutterBeacon.isBroadcasting();
    // if(isBroad == true){
    //   flutterBeacon.stopBroadcast();
    // }
    final box = GetStorage();
    teamId = box.read('tid');
    //animation
    meterController = AnimationController(
      // animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    animation =
        CurvedAnimation(parent: meterController, curve: Curves.easeInOutCubic);
    //animation

    //stream of location changes wrt to clue location
    // locationStream.resume();
  }

  @override
  void dispose() {
    meterController.dispose();
    if (Platform.isAndroid) {
      flutterBeacon.stopBroadcast();
    } else if (Platform.isIOS) {
      beaconBroadcast.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //location stream
    //StreamSubscription<Position>
    locationStream = Geolocator.getPositionStream().listen(
        //error
        onError: (error) async {
      // print("Error: $error");
      Widget dialog(context) {
        var pressed = ValueNotifier(false);
        return AlertDialog(
          title: const Text("Location Disabled"),
          // content: Text("Error: $error"),
          //styling
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white.withOpacity(0.2),
          //styling
          actions: [
            ValueListenableBuilder(
                valueListenable: pressed,
                builder: (context, value, child) {
                  bool check = false;
                  return (!pressed.value)
                      ? TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.black.withOpacity(0.2)),
                          ),
                          onPressed: () async {
                            try {
                              pressed.value = true;
                              await Geolocator.getCurrentPosition();
                              check =
                                  await Geolocator.isLocationServiceEnabled();
                              //debugPrint('check: $check');
                              if (check == true) {
                                if (!mounted) return;

                                Navigator.of(context).pop('dialog');
                              }
                            } catch (e) {
                              debugPrint("Error check: $e");
                            } finally {
                              pressed.value = false;
                            }
                          },
                          child: const Text(
                            "Grant Permission",
                            style: TextStyle(color: Colors.blueGrey),
                          ))
                      : const CircularProgressIndicator();
                })
          ],
        );
      }

      return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return WillPopScope(
            onWillPop: () async => false ,
            child: Transform.scale(scale: a1.value, child: dialog(context)));
        },
        transitionDuration: const Duration(milliseconds: 150),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return dialog(context);
        },
      );
    }, (Position position) async {
      //get mock location

      //print("Position: ${position.isMocked}");
      if (position.isMocked) {
        //show dialog to notify that user is using mock location
        //steps to disable it
        //warning that it will lead to disqualification if not disabled before restarting the app again
        //write to local storage the number of times the user has been caught using mock location

        final box = GetStorage();
        int mockCount = box.read('mockCount') ?? 0;
        mockCount++;
        box.write('mockCount', mockCount);
        if (mockCount > 3) {
          //show dialog
          DatabaseReference ref =
              FirebaseDatabase.instance.ref().child("$fbTeam/$teamId"); //team string
          await ref.update({
            "state": "Banned",
          });
          Get.closeAllSnackbars();
          GenericUtil.fancySnack(
              "Disqualified", "You've been banned for using mock location");
          GenericUtil.logout();
        }
        locationStream.cancel();
        //print("Mock Count: $mockCount");
        await showGeneralDialog(
            context: context,
            barrierDismissible: false,
            pageBuilder: (context, animation1, animation2) {
              return WillPopScope(
                onWillPop: () => Future.value(false),
                child: Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Mock Location Detected"),
                        const Text(
                            "Please disable mock location\nAnd restart the app to continue playing"),
                        TextButton(
                            onPressed: () async {
                              //close dialog
                              // Position newPosition =
                              //     await Geolocator.getCurrentPosition();
                              // if (!newPosition.isMocked) {
                              //   i
                              // }
                              exit(0);
                            },
                            child: const Text("Close"))
                      ],
                    ),
                  ),
                ),
              );
            });
        //Future.delayed(const Duration(hours: 100));
        //expected behaviour is to wait here but it continues ahead even though the dialog is still open
        //(instead of waiting for the user to close the dialog)
        //multiple dialogs are opened
      }
      //print("ahead of mock");
      // Handle position changes
      speed.value = position.speed;
      // debugPrint("Speed(mps): ${5position.speed}");
      distanceBetween(position.latitude, position.longitude, clueLat, clueLong);
      // debug print
      // debugPrint("lat: $clueLat");
      // debugPrint("long: $clueLong");
      //debugPrint("dbw: ${distance.value}");
      // bearingBetween(position.latitude, position.longitude, clueLat, clueLong);
      //animation
      if ((distance.value <= 500 && !animated) ||
          homeController.is_meter_off.value) {
        //if within range of 1500 and not animated
        meterController.forward();
        animated = true;
      } else if (distance.value > 500 && animated) {
        //if out of range of 1500 and animated
        meterController.reverse();
        animated = false;
      }
      //print('homeController.is_freexe: ${homeController.is_freezed.value}');
      if (distance.value <= 100 &&
          !beaconBroadcasting &&
          !homeController.is_freezed.value) { //if within range of 100 and not broadcasting and not freezed
        //if within range of 100 and not broadcasting and not freezed
        // print('also here');
        if (Platform.isIOS) {
          beaconBroadcast
              .setUUID("00000000-0000-0000-0000-000000000$teamId")
              .setIdentifier('techRace${homeController.clueNo}')
              .setMajorId(0)
              .setMinorId(0)
              .start();
        } else if (Platform.isAndroid) {
          flutterBeacon.startBroadcast(BeaconBroadcast(
              proximityUUID: "0$teamId",
              major: 0,
              minor: 0,
              identifier: 'techRace${homeController.clueNo}'));
        }
        beaconBroadcasting = true;
        // } catch (e) {
        //   debugPrint("Error: $e");
        // }

        //print('broadcasting');
      }
      if ((distance.value > 100 && beaconBroadcasting) ||
          (homeController.is_freezed.value && beaconBroadcasting)) { //if out of range of 100 and broadcasting or freezed and broadcasting
        //flutterBeacon.stopBroadcast();
        // print('here');
        if (Platform.isAndroid) {
          flutterBeacon.stopBroadcast();
        } else if (Platform.isIOS) {
          beaconBroadcast.stop();
        }

        // if (Platform.isAndroid) {
        //   flutterBeacon.stopBroadcast();
        // } else if (Platform.isIOS) {
        //   beaconBroadcast.stop();
        // }

        beaconBroadcasting = false;
        // print("stopped broadcasting");
      }

      //animation
    });
    //location stream
    //start stream
    //locationStream.resume();

    // is_meter_off toh dikhana hi hai
    return SizeTransition(
      sizeFactor: animation,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform.rotate(
          angle: 3.14,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ValueListenableBuilder(
              valueListenable: distance,
              builder: (context, value, child) {
                return Obx(
                  () => Container(
                    width: 16,
                    height: 200,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2,
                          spreadRadius: 1,
                          offset: Offset(0, 0),
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),

                      // here

                      gradient: LinearGradient(
                        tileMode: TileMode.decal,
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: homeController.is_meter_off.value
                            ? [
                                Colors.orange,
                                Colors.orange
                                // Color.fromARGB(255, 54, 140, 193),
                                // Colors.red
                              ]
                            :
                            // [Colors.red, Color.fromARGB(255, 54, 140, 193)],
                            [Color.fromARGB(255, 54, 140, 193), Colors.red],
                        stops: [
                          distance.value / 500 - 0.05,
                          distance.value / 500 + 0.05
                        ],
                        // stops: [0.3, 0.4],
                      ),
                    ),
                    child: const SizedBox(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
