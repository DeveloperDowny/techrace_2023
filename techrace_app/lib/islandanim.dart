import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/utils/MLocalStorage.dart';
import 'package:techrace/utils/MStyles.dart';

class DynamicIslandAnimated extends StatefulWidget {
  const DynamicIslandAnimated({super.key});

  // final String textToNotify;

  // DynamicIslandAnimated({super.key, required this.textToNotify});

  // const DynamicIslandAnimated({super.key});

  @override
  State<DynamicIslandAnimated> createState() => _DynamicIslandAnimatedState();
}

class _DynamicIslandAnimatedState extends State<DynamicIslandAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  final HomeController homeController2 = Get.find<HomeController>();

  late String textToShow;

  @override
  void initState() {
    super.initState();

    homeController2.animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // homeController2.animationController = controller;
    // homeController2.animationController.forward();
    // animation =
    //     CurvedAnimation(parent: homeController2.animationController, curve: Curves.easeInOutSine);
    animation = CurvedAnimation(
        parent: homeController2.animationController,
        curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    homeController2.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(homeController2 is HomeController); // yes you get home controller this way without drilling
    // print(homeController2.is_freezed.value);
    // if (widget.textToNotify != "") {
    //   controller.forward();
    // controller.
    // }

    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 39, 34, 34), width: 2),
            // color: const Color.fromARGB(255, 179, 207, 226).withOpacity(0.5),
            // color: Color(0xFF121826),
            color: MStyles.pColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: ScrollController(),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: ScreenUtil().screenWidth * 0.8),
                      child: Row(
                        // key: rowKey,
                        mainAxisSize: MainAxisSize.min,

                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon(
                          //   Icons.adb,
                          //   color: Color.fromARGB(255, 55, 57, 55),
                          //   size: 30,
                          // ),
                          // SizedBox(
                          //   width: 10,
                          // ),
                          // Obx(
                          //   () => ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 16, bottom: 8, right: 16),
                              child: Text(
                                  // 'Dynamic Island (ADs/leaderboard)',
                                  homeController2.textToShowDI.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,

                                  )),
                            ),
                          ),

                          Obx(() => !homeController2.isLoading.value ? SizedBox() : Container(padding: EdgeInsets.only(top: 8, bottom: 8, right: 16), child: CircularProgressIndicator(color: Colors.white.withOpacity(0.75),)))


                          // homeController2.timeLeftForReversal.value <= 500
                          //     ? Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: CircularCountDownTimer(
                          //             textFormat: CountdownTextFormat.SS,
                          //             controller: homeController2.reversalCountdownController,
                          //             isReverse: true,
                          //             isReverseAnimation: true,
                          //             isTimerTextShown: true,
                          //             autoStart: true,
                          //             width: 50,
                          //             height: 50,
                          //             duration: homeController2.timeLeftForReversal.value,
                          //             fillColor: MStyles.pColor,
                          //             ringColor: Colors.white,
                          //             onComplete: () {
                          //               debugPrint('Countdown Ended');
                          //               homeController2.timeLeftForReversal.value = 999;
                          //             }),
                          //       )
                          //     : Container()

                          // ),
                        ],
                      ),
                    ),
                    homeController2.timeLeftForReversal.value <= 60 &&
                            homeController2.freezed_by.value != "-999"
                        ? Container(
                            margin:
                                EdgeInsets.only(top: 8, left: 16, right: 16),
                            child: ElevatedButton(
                                onPressed: () {
                                  homeController2.reverseFreeze();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Reverse Freeze",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.w,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularCountDownTimer(
                                          textFormat: CountdownTextFormat.SS,
                                          controller: homeController2
                                              .reversalCountdownController,
                                          isReverse: true,
                                          isReverseAnimation: true,
                                          isTimerTextShown: true,
                                          autoStart: true,
                                          width: 30,
                                          height: 30,
                                          textStyle: TextStyle(
                                              fontSize: 13.w,
                                              color: Colors.white),
                                          strokeWidth: 3,
                                          duration: homeController2
                                              .timeLeftForReversal.value,
                                          fillColor: MStyles.pColor,
                                          ringColor: Colors.white,
                                          onComplete: () {
                                            debugPrint('Countdown Ended');
                                            homeController2.timeLeftForReversal
                                                .value = 999;
                                          }),
                                    )
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                style: ElevatedButton.styleFrom(
                                    // backgroundColor: Color(0xFF121826),
                                    // backgroundColor: Color(0xFF121826),
                                    // backgroundColor: Color(0xFf882edc),
                                    backgroundColor: Color(0xff222257),
                                    minimumSize: Size(
                                        ScreenUtil().screenWidth * 0.7, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)))
                                    // shape: BeveledRectangleBorder(
                                    //     borderRadius:
                                    //     BorderRadius.all(Radius.circular(10.w)
                                    //     )
                                    // )
                                    )
                                // ButtonStyle(
                                //     shape: MaterialStateProperty.all(
                                //       BeveledRectangleBorder(
                                //           borderRadius: BorderRadius.all(Radius.circular(4))),
                                //     )).copyWith(
                                //   minimumSize: Size.fromHeight(50)
                                // ),
                                ),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          //reverse freeze wala
          if (homeController2.timeLeftForReversal <= 60 && homeController2.freezed_by.value != "-999") return; //check this
          homeController2.animationController.reverse(); //yeh nai hai
        },
      ),
    );
  }
}

// class AnimatedIsland extends AnimatedWidget {
//   const AnimatedIsland({super.key, width}) : super(listenable: width);

//   @override
//   Widget build(BuildContext context) {
//     return const DynamicIslandAnimated();
//   }
// }
