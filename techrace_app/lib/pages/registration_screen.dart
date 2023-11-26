import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/controllers/StateController.dart';
import 'package:techrace/pages/login_screen.dart';
import 'package:get/get.dart';
import 'package:techrace/utils/GenericUtil.dart';
import 'package:techrace/utils/MLocalStorage.dart';

//beacon
import 'package:beacon_broadcast/beacon_broadcast.dart' as iB;
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:techrace/utils/carousel.dart';

class RegistrationScreen extends StatefulWidget {
  final String teamId;

  RegistrationScreen({Key? key, required this.teamId}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  StateController stateController = StateController();

  final verifyPasscodeController = TextEditingController();

  @override
  void dispose() {
    // homeController.homeModel.sub1.cancel(); //technically is not required
    Get.delete<StateController>();
    stateController.dispose(); //what about the reg screen wala part
    print(stateController.isClosed); //it is not closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Stack(
          alignment: Alignment.center,

          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Flexible(
                  child: Material(
                    elevation: 0,
                    // borderOnForeground: true,
                    clipBehavior: Clip.antiAlias,
                    shape: BeveledRectangleBorder(
                      // side: BorderSide(color: Colors.blue), if you need
                      borderRadius: BorderRadius.only(
                          // topLeft: Radius.circular(0),
                          // topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(27.w),
                          bottomRight: Radius.circular(27.w)),
                    ),

                    child: Container(
                      height: ScreenUtil().screenHeight * 0.7 + 4,

                      // width: 100,
                      decoration: const BoxDecoration(
                          color: Color(0xff2e92da),
                          border: Border(
                              bottom: BorderSide(// width: 10
                                  // width: 100
                                  ))
                          // borderRadius: BorderRadius.circular(15.0),
                          ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Flexible(
                  child: Material(
                    elevation: 0,
                    // borderOnForeground: true,
                    clipBehavior: Clip.antiAlias,
                    shape: BeveledRectangleBorder(
                      // side: BorderSide(color: Colors.blue), if you need
                      borderRadius: BorderRadius.only(
                          // topLeft: Radius.circular(0),
                          // topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(27.w),
                          bottomRight: Radius.circular(27.w)),
                    ),

                    child: Container(
                      height: ScreenUtil().screenHeight * 0.7,

                      // width: 100,
                      decoration: const BoxDecoration(
                          color: Color(0xff121827),
                          border: Border(
                              bottom: BorderSide(// width: 10
                                  // width: 100
                                  ))
                          // borderRadius: BorderRadius.circular(15.0),
                          ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 70.w),
                child: Image.asset(
                  "assets/images/techrace_logo.png",
                  // height: 100.w,
                  width: ScreenUtil().screenWidth * 0.7,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "PLEASE HEAD TO THE\nREGISTRATION DESK",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.w, fontWeight: FontWeight.w300),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  height: ScreenUtil().screenWidth * 0.6,
                  width: ScreenUtil().screenWidth * 0.6,
                  // child: QrImage(
                  //   backgroundColor: Colors.white,
                  //   errorCorrectionLevel: QrErrorCorrectLevel.M,
                  //   data: MLocalStorage().getTeamID(),
                  //   version: QrVersions.auto,
                  //   // size: 200.0,
                  // ) as Widget,
                  child:  QrImageView(data: MLocalStorage().getTeamID(), size: 200.0,
                  ),
                )
                // add qr code here
                // Text(
                //   widget.teamId,
                //   style: TextStyle(fontSize: 74.w, fontWeight: FontWeight.bold),
                // ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Team ${widget.teamId}",
                    style: TextStyle(fontSize: 18.w),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 26.w, vertical: 30.w),
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: ((context) => VerificationWidget(
                                  verifyPasscodeController:
                                      verifyPasscodeController))).then((value) {
                            verifyPasscodeController.text = "";
                            //      if beacon on switch it off
                            // todo switch off beacon
                          });

                          // showDialog(context: context, builder: Dialog)
                          // GenericUtil.logout();
                          // test beacon here

                          //
                          // Api().logout();
                          //
                          // Get.off(() => LoginScreen());
                        },
                        child: Text("VERIFY PHONE SETTINGS",
                            style: TextStyle(
                                fontSize: 18.w, fontWeight: FontWeight.w700)),
                        clipBehavior: Clip.antiAlias,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: BeveledRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.w))))
                        // ButtonStyle(
                        //     shape: MaterialStateProperty.all(
                        //       BeveledRectangleBorder(
                        //           borderRadius: BorderRadius.all(Radius.circular(4))),
                        //     )).copyWith(
                        //   minimumSize: Size.fromHeight(50)
                        // ),
                        ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: const Color(0xcc2e92da),
                radius: 20,
                child: IconButton(
                    // color: Colors.blue,
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CarouselApp2();
                          });
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 15,
                    )),
              ),
            ),
            Positioned(
              // 8, 20, 0, 0
              top: 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: const Color(0xcc2e92da),
                radius: 20,
                child: IconButton(
                    // color: Colors.blue,

                    onPressed: () {
                      GenericUtil.logout();
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 15,
                    )),
              ),
            )
          ],
        )),
      ),
    );
  }
}

class VerificationWidget extends StatefulWidget {
  const VerificationWidget({
    super.key,
    required this.verifyPasscodeController,
  });

  final TextEditingController verifyPasscodeController;

  @override
  State<VerificationWidget> createState() => _VerificationWidgetState();
}

class _VerificationWidgetState extends State<VerificationWidget> {
  late iB.BeaconBroadcast beaconBroadcast;
  RxBool isAdmin = false.obs;
  RxBool isBroadcasting = false.obs;
  // String tid = MLocalStorage.tid;
  String tid = MLocalStorage().getTeamID();

  checkBeacon() async {
    bool isBroad = await flutterBeacon.isBroadcasting();
    //print("broadcasting: $isBroad");
    isBroadcasting.value = isBroad;
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkBeacon();
      });
    } else if (Platform.isIOS) {
      beaconBroadcast = iB.BeaconBroadcast();
    }
    print('tid: $tid');
  }

  @override
  void dispose() {
    super.dispose();
    if (Platform.isAndroid) {
      flutterBeacon.stopBroadcast();
    } else if (Platform.isIOS) {
      beaconBroadcast.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff121827),
      // backgroundColor: Theme.of(context).primaryColorDark,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.verifyPasscodeController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Admin Verification Code",
                // helperText:
                // // "What's do you think is the location (name only not address)?\nE.g. The Taj Mahal Hotel",
                // "NOTE: Don't enter address. Only the name of the location you have guessed.\nExample1: The Taj Hotel\nExample 2: Galaxy Appartments",
                // helperMaxLines: 10
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Obx(() => (isAdmin.value)
                ? TextButton(
                    onPressed: () {
                      if (isBroadcasting.value) {
                        if (Platform.isAndroid) {
                          flutterBeacon.stopBroadcast();
                        } else if (Platform.isIOS) {
                          beaconBroadcast.stop();
                        }
                        isBroadcasting.value = false;
                      } else {
                        if (Platform.isAndroid) {
                          flutterBeacon.startBroadcast(BeaconBroadcast(
                              proximityUUID: "0$tid",
                              major: 0,
                              minor: 0,
                              identifier: 'techRace'));
                        } else if (Platform.isIOS) {
                          beaconBroadcast
                              .setUUID("00000000-0000-0000-0000-000000000$tid")
                              .setIdentifier('techRace')
                              .setMajorId(0)
                              .setMinorId(0)
                              .start();
                        }
                        isBroadcasting.value = true;
                      }
                    },
                    child: (isBroadcasting.value)
                        ? const Icon(Icons.location_on)
                        : const Icon(Icons.location_off),
                  )
                : Container()),
            ElevatedButton(
                onPressed: () {
                  if (widget.verifyPasscodeController.text != "bv") {
                    Get.closeAllSnackbars();
                    GenericUtil.fancySnack("Failed", "Incorrect Password");
                    return;
                  }
                  Get.closeAllSnackbars();
                  GenericUtil.fancySnack("Success", "Verification Started");
                  isAdmin.value = true;
                  // homeController
                  //     .guessedLocationFunction();

                  //todo emit beacon here
                },
                child: Text("VERIFY",
                    style:
                        TextStyle(fontSize: 18.w, fontWeight: FontWeight.w700)),
                clipBehavior: Clip.antiAlias,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)))))
          ],
        ),
      ),
    );
  }
}


// a1.
// At this point, I should be listening to the realtime database to be listening
// for my status.
// 1st state will be waiting_for_reg
// 2nd state will be waiting_for_game_start // this page should show the countdown
// timer
// 3rd state will be playing