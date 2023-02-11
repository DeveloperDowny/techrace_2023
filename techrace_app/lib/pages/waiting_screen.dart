import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:circular_countdown_timer/countdown_text_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/controllers/WaitingController.dart';
import 'package:techrace/home.dart';
import 'package:techrace/utils/GenericUtil.dart';
import 'package:techrace/utils/MStyles.dart';

import '../utils/carousel.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  // final int _duration = 60 * 60;
  final int _duration = 10;

  // final WaitingController waitingController = WaitingController();
  final WaitingController waitingController = Get.put(WaitingController());

  @override
  void dispose() {
    Get.delete<WaitingController>();
    waitingController.dispose(); //what about the reg screen wala part
    print(waitingController.isClosed); //it is not closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _controller.restart()
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Flexible(
                  child: Material(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(200.h),
                          topLeft: Radius.circular(200.h)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff2e92da),
                          border: Border(bottom: BorderSide())),
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
                    clipBehavior: Clip.antiAlias,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(225.h),
                          topLeft: Radius.circular(225.h)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff121827),
                          border: Border(bottom: BorderSide())),
                    ),
                  ),
                ),
              ],
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Race Will Start In",
                    style: TextStyle(
                        fontSize: 20.w,
                        fontWeight: FontWeight.bold,
                        fontFamily: "TTOcto",
                        fontStyle: FontStyle.italic),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: GenericUtil.beveledParent(15.0,
                //       child: Text(
                //         "Race Will Start In",
                //         style: TextStyle(
                //           fontSize: 20.w,
                //             fontWeight: FontWeight.bold,fontFamily: "TTOcto", fontStyle: FontStyle.italic),
                //       )),
                // ),
                CircularCountDownTimer(
                  // duration: _duration,
                  duration: waitingController.timeLeft.value,
                  initialDuration: 0,
                  controller: waitingController.controller,
                  width: MediaQuery.of(context).size.width / 2,
                  height: 250.h,
                  // height: MediaQuery.of(context).size.height / 2,
                  ringColor: Colors.grey[300]!,
                  ringGradient: null,
                  // fillColor: Colors.purpleAccent[100]!,
                  fillColor: Color(0xff2e92da),
                  fillGradient: null,
                  // backgroundColor: Colors.purple[500],
                  // backgroundColor: Color(0xFF2E92DA) ,
                  backgroundColor: Color(0xff121827),
                  backgroundGradient: null,
                  // strokeWidth: 20.0,
                  strokeWidth: 10.0,
                  strokeCap: StrokeCap.round,
                  textStyle: const TextStyle(
                    fontSize: 33.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textFormat: CountdownTextFormat.HH_MM_SS,
                  isReverse: true,
                  isReverseAnimation: true,
                  isTimerTextShown: true,
                  autoStart: true,
                  onStart: () {
                    debugPrint('Countdown Started');
                  },
                  onComplete: () {
                    debugPrint('Countdown Ended');
                    // Api().changeStateToPlaying(); // don't make this change
                    // do this from server
                    Get.off(() => Home()); //
                  },
                  onChange: (String timeStamp) {
                    debugPrint('Countdown Changed $timeStamp');
                  },

                  timeFormatterFunction: (defaultFormatterFunction, duration) {
                    if (duration.inSeconds == 0) {
                      return "GO";
                    } else {
                      return Function.apply(
                          defaultFormatterFunction, [duration]);
                    }
                  },
                ),
              ],
            ),
            // Obx(
            //   () => ,
            // ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: ElevatedButton(
            //       onPressed: () {
            //         _controller.start();
            //       },
            //       child: Text("Theme.of(context)")),
            // )

            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: MStyles.buildElevatedButton(() {}, "LOGOUT"),
            //   ),
            // )

            Positioned(
                // 8, 20, 0, 0
                top: 16,
                left: 16,
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
          ],
        )),
      ),
    );
  }

  Widget _button({required String title, VoidCallback? onPressed}) {
    return Expanded(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
