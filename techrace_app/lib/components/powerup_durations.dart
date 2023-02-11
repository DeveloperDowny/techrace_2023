import 'dart:ffi';
import 'dart:ui';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/utils/MStyles.dart';

class PowerUpDurations extends StatefulWidget {
  const PowerUpDurations({Key? key}) : super(key: key);

  @override
  State<PowerUpDurations> createState() => _PowerUpDurationsState();
}

class _PowerUpDurationsState extends State<PowerUpDurations> {
  final HomeController homeController = Get.find<HomeController>();

  // late int timeLeftForUnfreeze;
  // late int timeLeftForFreezeCooldown;
  // late int timeLeftForMeterOff;
  // late int timeLeftForMeterOffCooldown;
  // late int timeLeftForInvisibility;

  late int timeLeft2freezeDuration;
  late int timeLeft2freezeCooldownDuration;
  late int timeLeft2meterOffDuration;
  late int timeLeft2meterOffCooldownDuration;
  late int timeLeft2invisibilityDuration;
  late int timeLeft2hint1LockDuration;
  late int timeLeft2hint2LockDuration;

  static int getTimeDiffInSeconds(bigger, int biggerBias, smaller) {
    var timeUntilrev = DateTime.parse(bigger);
    timeUntilrev = timeUntilrev.add(Duration(seconds: biggerBias));

    // final now = DateTime.parse(smaller);
    final now = smaller;
    // return timeUntilrev.difference(now).inSeconds;
    return timeUntilrev.difference(now).inSeconds;
  }




  // // change times here //old
  // static final int freezeDuration = (7.5 * 60).toInt();
  // static final int freezeCooldownDuration = (10 * 60).toInt();
  // static final int meterOffDuration = (7.5 * 60).toInt();
  // static final int meterOffCooldownDuration = (7.5 * 60).toInt();
  // static final int invisibilityDuration = (7.5 * 60).toInt();
  // static final int hint1LockDuration = (5 * 60).toInt();
  // static final int hint2LockDuration = (10 * 60).toInt();


  // // in seconds //new
  // const freezeDuration = 10 * 60;
  // const freezeCooldownDuration = 10 * 60;
  // const meterOffDuration = 15 * 60;
  // const meterOffCooldownDuration = 0 * 60;
  // const invisibilityDuration = 10 * 60;
  // const hint1LockDuration = 5 * 60;
  // const hint2LockDuration = 10 * 60;
  // change times here

  static final int freezeDuration = (10 * 60).toInt();
  // static final int freezeCooldownDuration = (10 * 60).toInt();
  static final int freezeCooldownDuration = (15 * 60).toInt(); //changed
  static final int meterOffDuration = (15 * 60).toInt();
  static final int meterOffCooldownDuration = (0 * 60).toInt();
  static final int invisibilityDuration = (10 * 60).toInt();
  static final int hint1LockDuration = (5 * 60).toInt();
  static final int hint2LockDuration = (10 * 60).toInt();



  @override
  void initState() {
    initTimeLefts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const we = 50.0;
    const h = 50.0;
    const rad = 50.0;
    // show ki konsa konsa time baki hai
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Scaffold(

          backgroundColor: Colors.transparent,

        // backgroundColor: Colors.transparent,
        // backgroundColor: MStyles.darkBgColor.withOpacity(0.25),//udhar se le
        // backgroundColor: MStyles.darkBgColor.withOpacity(0.25),//udhar se le
          body: Center(
            child: Container(
              // padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

              timeLeft2freezeDuration <=0 &&
              timeLeft2freezeCooldownDuration <=0 &&
              timeLeft2meterOffDuration <=0 &&
              // timeLeft2meterOffCooldownDuration <=0 &&
              timeLeft2invisibilityDuration <=0 &&
              timeLeft2hint1LockDuration <=0 &&
              timeLeft2hint2LockDuration <=0 ? Container(
                  padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16  ),
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: MStyles.materialColor,borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("No Active Power Cards Applied on You Currently"),
              ),
            ): SizedBox(),

                  // timeLeft2hint2LockDuration < 0 ? SizedBox() : CircularCountDownTimer(width: we, height: h, duration: timeLeft2hint2LockDuration, fillColor: Colors.white, ringColor: MStyles.pColor)
                  timeLeft2hint1LockDuration <= 0 ? SizedBox() : buildCircularCountDownTimerForStatus(timeLeft2hint1LockDuration, "Hint 1 will be unlocked in: ", 1, hint1LockDuration),
                  timeLeft2hint2LockDuration <= 0 ? SizedBox() : buildCircularCountDownTimerForStatus(timeLeft2hint2LockDuration, "Hint 2 will be unlocked in: ", 2, hint2LockDuration),
                  timeLeft2freezeDuration <= 0 ? SizedBox() : buildCircularCountDownTimerForStatus(timeLeft2freezeDuration, "You'll be unfreezed in: ", 3, freezeDuration),
                  !(timeLeft2freezeDuration <= 0 && timeLeft2freezeCooldownDuration >=0) ? SizedBox() : buildCircularCountDownTimerForStatus(timeLeft2freezeCooldownDuration, "You have Freeze Shield for: ", 4, freezeDuration + freezeCooldownDuration),
                 timeLeft2meterOffDuration <= 0 ? SizedBox() : buildCircularCountDownTimerForStatus(timeLeft2meterOffDuration, "Your meter will be turned on in: ", 5, meterOffDuration),
                  // !( timeLeft2meterOffDuration <= 0 && timeLeft2meterOffCooldownDuration >=0) ? SizedBox() : buildCircularCountDownTimerForStatus(timeLeft2meterOffCooldownDuration, "You have Meter Off Shield for: ", 6, meterOffDuration + meterOffCooldownDuration),
                  timeLeft2invisibilityDuration <= 0 ? SizedBox() : buildCircularCountDownTimerForStatus(timeLeft2invisibilityDuration, "You will become visible again in: ", 7, invisibilityDuration),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      // backgroundColor: Color(0xcc2e92da),
                      backgroundColor: Colors.white,
                      radius: 24,
                      child: IconButton(
                        // color: Colors.blue,

                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.close,
                            // color: Colors.white,
                            // color: Colors.black26,
                            color: MStyles.pColor,
                            size: 20,
                          )),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget buildCircularCountDownTimerForStatus(int mduration, String whoseTimer, int timerId, int initialDuration) {
    const rad = 50.0;
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16  ),
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: MStyles.materialColor,borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(whoseTimer, style: MStyles.mTextStyle.copyWith(fontWeight: FontWeight.normal, fontSize: 16.w),),
            // SizedBox(width: 32,),
            CircularCountDownTimer(
                    textFormat: CountdownTextFormat.MM_SS,
                    // controller: homeController2
                    //     .reversalCountdownController,
                    isReverse: true,
                    isReverseAnimation: true,
                    isTimerTextShown: true,
                    autoStart: true,
                    width: rad,
                    height: rad,
                    textStyle: TextStyle(
                        fontSize: 13.w,
                        color: Colors.white),
                    strokeWidth: 3,
                    // duration: mduration,
                    // initialDuration: initialDuration,
                duration: initialDuration,
                    initialDuration: initialDuration - mduration,
                    // homeController2
                        // .timeLeftForReversal.value,
                    fillColor: MStyles.pColor,
                    ringColor: Colors.white,
                    onComplete: () {
                      debugPrint('Countdown Ended');
                      switch(timerId) {
                        case 2:
                          timeLeft2hint2LockDuration = -999;
                          setState(() {
                          });
                          break;
                        case 1:
                          timeLeft2hint1LockDuration = -999;
                          setState(() {
                          });
                          break;
                        case 3:
                          timeLeft2freezeDuration = -999;
                          setState(() {

                          });
                          break;
                          case 4:
                          timeLeft2freezeCooldownDuration = -999;
                          setState(() {
                          });
                          break;
                          case 5:
                          timeLeft2meterOffDuration = -999;
                          setState(() {
                          });
                          break;
                          case 6:
                          timeLeft2meterOffCooldownDuration = -999;
                          setState(() {
                          });
                          break;
                          case 7:
                          timeLeft2invisibilityDuration = -999;
                          setState(() {
                          });
                          break;
                      }
                      // homeController2.timeLeftForReversal
                      //     .value = 999;
                    }),
          ],
        ),
      ),
    );
  }

  void initTimeLefts() {
    timeLeft2freezeDuration = getTimeDiffInSeconds(
        homeController.freezed_on, freezeDuration, DateTime.now());
    timeLeft2freezeCooldownDuration = getTimeDiffInSeconds(
        homeController.freezed_on,
        freezeDuration + freezeCooldownDuration,
        DateTime.now());
    timeLeft2meterOffDuration = getTimeDiffInSeconds(
        homeController.meter_off_on, meterOffDuration, DateTime.now());
    timeLeft2meterOffCooldownDuration = getTimeDiffInSeconds(
        homeController.meter_off_on,
        meterOffDuration + meterOffCooldownDuration,
        DateTime.now());
    timeLeft2invisibilityDuration = getTimeDiffInSeconds(
        homeController.invisible_on, invisibilityDuration, DateTime.now());
    timeLeft2hint1LockDuration = getTimeDiffInSeconds(
        homeController.prevClueSolvedTimeStamp.value,
        hint1LockDuration,
        DateTime.now());
    timeLeft2hint2LockDuration = getTimeDiffInSeconds(
        homeController.prevClueSolvedTimeStamp.value,
        hint2LockDuration,
        DateTime.now());

    // print("timeLeft2freezeDuration");
    // print(timeLeft2freezeDuration);
    //
    // print("timeLeft2freezeCooldownDuration");
    // print(timeLeft2freezeCooldownDuration);
    //
    // print("timeLeft2meterOffDuration");
    // print(timeLeft2meterOffDuration);
    //
    // print("timeLeft2meterOffCooldownDuration");
    // print(timeLeft2meterOffCooldownDuration);
    //
    // print("timeLeft2invisibilityDuration");
    // print(timeLeft2invisibilityDuration);
    //
    // print("timeLeft2hint1LockDuration");
    // print(timeLeft2hint1LockDuration);

    print("timeLeft2hint2LockDuration");
    print(timeLeft2hint2LockDuration);
  }
}
