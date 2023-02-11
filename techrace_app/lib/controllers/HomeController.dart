import 'dart:ui';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/model/HomeModel.dart';
import 'package:techrace/utils/GenericUtil.dart';
import 'package:techrace/utils/MLocalStorage.dart';
import 'package:techrace/utils/MStyles.dart';
import 'package:techrace/utils/PowerUps.dart';

class HomeController extends GetxController {
  final clueNo = 0.obs;
  final points = 0.obs;
  final clueData = (Map.from({"clue": "CLUE"})).obs;
  var reversalCountdownController = CountDownController();

  // final stateModel = StateModel(currentState);
  // late GameModel gameModel;
  // what things need to be observed for freeze team
  // balance vagaire ka bhi track idhar se hi rakh sakte hai and then can use dynamic island to apply things
  // filhaal keep things simple
  // I don't need cannot freeze till
  // I just need

  // final clueNo = 0.obs;
  // final points = 0.obs;
  // final clueData = (Map.from({"clue": "CLUE"})).obs;

  // final stateModel = StateModel(currentState);

  final is_freezed = false.obs;
  final is_meter_off = false.obs;
  final isLoading = false.obs;
  var loadingTextToShow = "";

  //  var is_meter_off;
  // final optionOfReverseFreezeTill = "-999".obs;
  final timeLeftForReversal = 999.obs;

  late HomeModel homeModel;

  final textToShowDI = "".obs;

  late AnimationController animationController;

  final oppTid = "-999".obs;
  final freezed_by = "-999".obs;

  final powerCard = PowerUps.blank.obs;

  final TextEditingController guessedString = TextEditingController();

  final prevClueSolvedTimeStamp = MLocalStorage().getStartDateTime().obs;

  var freezed_on = "";
  var meter_off_on = "";
  var invisible_on = "";

  // var freezed_by; //if -999 toh yehi use karo

  // final powerCard = PowerUps.blank.obs;
  // AnimationController animController = AnimationController(
  //   duration: const Duration(milliseconds: 1500),
  //   vsync: this,
  // )

  void toggleLoading({textToShow = "", afterText = ""}) {
    if (textToShow != "") {
      textToShowDI.value = textToShow;
      loadingTextToShow = textToShow;

      // isLoading.value = !isLoading.value;
      isLoading.value = true;
      if (textToShow == "Applying Reverse Freeze") {
        print("herer");
        return;}
      animationController.value = 0;
      animationController.forward(from: 0.5);
    } else {
      // animationController.value = 0;
      // textToShowDI.value = afterText;
      // animationController.forward(from: 0);

      animationController.reverse();
      Future.delayed(Duration(milliseconds: 2*1000), () => isLoading.value = false);
    }
  }

  HomeController() {
    homeModel = HomeModel(this);

    // is_freezed.listen((p0) {
    //   if (is_freezed.value) {
    //     Get.dialog(
    //         Dialog(
    //           child: Container(
    //             padding: EdgeInsets.all(16),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 TextField(
    //                   controller: guessedString,
    //                   decoration: InputDecoration(
    //                       border: OutlineInputBorder(),
    //                       labelText: "Location Name",
    //                       helperText:
    //                       // "What's do you think is the location (name only not address)?\nE.g. The Taj Mahal Hotel",
    //                       "NOTE: Don't enter address. Only the name of the location you have guessed.\nExample1: The Taj Hotel\nExample 2: Galaxy Appartments",
    //                       helperMaxLines: 10),
    //                 ),
    //                 SizedBox(height: 16,),
    //                 ElevatedButton(
    //                     onPressed: () {
    //                       guessedLocationFunction();
    //                     },
    //                     child: Text("GUESS", style: TextStyle(fontSize: 18.w, fontWeight: FontWeight.w700)),
    //                     clipBehavior: Clip.antiAlias,
    //                     style: ElevatedButton.styleFrom(
    //                         minimumSize: Size.fromHeight(50),
    //                         shape: BeveledRectangleBorder(
    //                             borderRadius:
    //                             BorderRadius.all(Radius.circular(10.w))))
    //                 )
    //
    //               ],
    //             ),
    //           ),
    //         )
    //     );
    //   }
    //
    // });
    // gameModel = GameModel(clueNo, points, clueData);

    // is_freezed.listen((p0) {
    //   if (p0) {}
    // });

    // oppTid.listen((p0) {
    //   Get.defaultDialog(
    //     title: "Use Power Card",
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [Text("one"), Text("two")],
    //     ),
    //
    //   );
    // });
  }

  @override
  void dispose() {
    print("here");
    homeModel.sub1.cancel();
    // gameModel.sub1.cancel();
    super.dispose();
  }

  Future<dynamic> applyPowerCard() async {
    toggleLoading(textToShow: "Applying Power Card");
    Get.back();
    Get.back();
    final res = await Api().usePowerUp(powerCard.value, oppTid.value,
        points.value, DateTime.now().millisecondsSinceEpoch, is_freezed.value);
    if (res["status"] == "0") {
      Get.closeAllSnackbars();
      // GenericUtil.fancySnack("Power Card Not Applied", res["message"]);
      Future.delayed(Duration(seconds: 1), ()=>
      // GenericUtil.fancySnack("Power Card Not Applied", res["message"]
      // GenericUtil.fancySnack("Power Card Not Applied", res["message"]
          GenericUtil.fancySnack("Power Card Not Applied",res["message"] )

      );
      // Get.back();
    } else {
      Get.closeAllSnackbars();
      // GenericUtil.fancySnack("Success", "Power Card Applied Successfully",
          // backgroundColor: MStyles.pColor);

      GenericUtil.fancySnack("Success", "Power Card Applied Successfully");
    }

    // debugging ke liye easy hoega do that
    toggleLoading(afterText: "Power Card Applied Successfully"); //temp
  }

  Future<void> getHint() async {
    HomeController homeController = Get.find<HomeController>();

    if (clueData["hint_1"] != "-999") {
      if (clueData["hint_2"] != "-999") {
        Get.closeAllSnackbars();
        GenericUtil.fancySnack(
            "No more hints", "Only two hints are available for this clue");
      } else {
        // var locTs = prevClueSolvedTimeStamp.value == "-999" ?
        print("Time test: ${prevClueSolvedTimeStamp.value}");
        if (DateTime.now()
                .difference(DateTime.parse(prevClueSolvedTimeStamp.value))
                .inSeconds <=
            10 * 60) {
          // showDialog(context: context, builder: (context) => {})

//           Get.dialog(
//
// );
          showHintDialog(() async {

            toggleLoading(textToShow: "Getting Hint");
            Get.back();
            // Get.back();

            final hint = await Api().getHint(
                homeController.clueData['cid'].toString(), points.value - 80);

            doWithGetHintRes(hint, false);
          }, // "UNLOCK FOR 75 POINTS",
              "80 TEC",
              "Hint 2 is locked at the moment.\n80 points to unlock it instantly.");
          return;
        } else {
          showHintDialog(() async {

            toggleLoading(textToShow: "Getting Hint");
            Get.back();
            final hint = await Api().getHint(
                homeController.clueData['cid'].toString(), points.value - 60);
            doWithGetHintRes(hint, true);
          }, "60 TEC", "Too Hard?");
          // Get.dialog(
          //   Dialog(
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Text("Too Hard?"), //"Unlock Hint 2 for 60 points"),
          //         MStyles.buildElevatedButton(() async {
          //           Get.back();
          //           final hint = await Api()
          //               .getHint(clueNo.value.toString(), points.value - 60);
          //           doWithGetHintRes(hint, true);
          //         }, "GET HINT FOR 60 POINTS")
          //       ],
          //     ),
          //   ),
          // );
        }
        // this is for hint 2
        // final hint = await Api().getHint(clueNo.value.toString());
        // doWithGetHintRes(hint);
        // clueData["hint_2"] = hint["hint_2"];
      }
    } else {
      // first hint is empty just pull it

      if (DateTime.now()
              .difference(DateTime.parse(prevClueSolvedTimeStamp.value))
              .inSeconds <=
          5 * 60) {
        print(DateTime.now()
                .difference(DateTime.parse(prevClueSolvedTimeStamp.value))
                .inSeconds <=
            5 * 60);

        print("""DateTime.now()
            .difference(DateTime.parse(prevClueSolvedTimeStamp.value))
            .inSeconds <=
            5 * 60""");
        print(DateTime.now()
            .difference(DateTime.parse(prevClueSolvedTimeStamp.value))
            .inSeconds);
        // showDialog(context: context, builder: (context) => {})
        showHintDialog(() async {

          toggleLoading(textToShow: "Getting Hint");
          Get.back();
          final hint = await Api().getHint(
              homeController.clueData['cid'].toString(), points.value - 50);
          doWithGetHintRes(hint, false);
        }, "5O TEC", "Hint 1 is locked at the moment.\n50 points to unlock it instantly.");
        // Get.dialog(Dialog(
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Text(
        //         "Hint 1 is locked at the moment.\n50 points to unlock it instantly.",
        //         style: MStyles.mTextStyle,
        //       ),
        //       MStyles.buildElevatedButton(() async {
        //         Get.back();
        //         final hint = await Api()
        //             .getHint(clueNo.value.toString(), points.value - 50);
        //         doWithGetHintRes(hint, false);
        //       }, "UNLOCK FOR 50 POINTS")
        //     ],
        //   ),
        // ));
        return;
      } else {
        showHintDialog(() async {

          toggleLoading(textToShow: "Getting Hint");
          Get.back();
          final hint = await Api().getHint(
              homeController.clueData['cid'].toString(), points.value - 40);
          doWithGetHintRes(hint, false);
        }, "40 TEC", "Too Hard?"); //GET HINT FOR 40 POINTS

        // Get.dialog(getHintDialog(() async {
        //   Get.back();
        //   final hint =
        //       await Api().getHint(clueNo.value.toString(), points.value - 40);
        //   doWithGetHintRes(hint, false);
        // }, "GET HINT FOR 40 POINTS", "Too Hard?")
        //
        //     //     Dialog(
        //     //   child: Column(
        //     //     mainAxisSize: MainAxisSize.min,
        //     //     children: [
        //     //       Text("Too Hard?"),
        //     //       MStyles.buildElevatedButton(() async {
        //     //         Get.back();
        //     //         final hint = await Api()
        //     //             .getHint(clueNo.value.toString(), points.value - 40);
        //     //         doWithGetHintRes(hint, false);
        //     //       }, "GET HINT FOR 40 POINTS")
        //     //     ],
        //     //   ),
        //     // )
        //
        //     );
      }

      // final hint = await Api().getHint(clueNo.value.toString());
      // if (hint["status"] == "0") {
      //   GenericUtil.fancySnack("Failed to get hint", hint["message"]);
      //   return;
      // }
      // clueData["hint_1"] = hint["hint_1"];
    }
  }

  void showHintDialog(Future<Null> Function() onButtonCLick, String textToShow,
      String dialogPromt) {
    Get.dialog(
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 3,
            sigmaY: 3,
          ),
          child: Dialog(
            // insetPadding: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            backgroundColor: Color(0xff121826),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dialogPromt, style: MStyles.mTextStyle),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Text(
                      "You can buy a hint to help you solve the clue using your points.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Your Points:  ${points.value} TEC",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.w),
                  )
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       // Text("Your Points:", style: MStyles.mTextStyle),
                  //       Text("Your Points:"),
                  //       Text("${points} TEC")
                  //     ],
                  //   ),
                  // )
                  ,
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child:
                        MStyles.buildElevatedButton(onButtonCLick, textToShow),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierColor: Colors.black26);
  }

  Future<void> doWithGetHintRes(hint, wasForHint2) async {

    await Future.delayed(Duration(seconds: 1));
    toggleLoading(afterText: "Hint Fetched Successfully");
    if (hint["status"] == "0") {
      Get.closeAllSnackbars();
      GenericUtil.fancySnack("Failed to get hint", hint["message"]);
      return;
    }

    // you just don't need this part

    // else {
    //   if (wasForHint2) {
    //     clueData["hint_2"] = hint["hint_2"];
    //   } else {
    //     clueData["hint_1"] = hint["hint_1"]; // hint_1 somehow becomes null
    //   }
    // }
  }

  // you can't use for last location
  Future<void> guessedLocationFunction() async {
    toggleLoading(textToShow: "Applying Skip a Location Power Card");

    Get.back();
    Get.back();
    final res = await Api().usePowerUp(
        PowerUps.guessLocation,
        "-999",
        points.value,
        DateTime.now().millisecondsSinceEpoch,
        is_freezed.value,
        guessedString.text);


    await Future.delayed(Duration(seconds: 1));
    toggleLoading(afterText: "Skip a Location Applied Successfully");

    Get.closeAllSnackbars();
    if (res["status"] == "1") {
      GenericUtil.fancySnack("Congratulations!",
          "You guessed it correctly!\nNext clue has been loaded.");
    } else if (res["status"] == "2") {
      GenericUtil.fancySnack("Oops", "Your guess was incorrect.");
    } else {
      GenericUtil.fancySnack("Failed", res["message"]);
    }
  }

  //reverse freeze click karne ke baad issue aa rahe hai
  Future<void> reverseFreeze() async {
    toggleLoading(textToShow: "Applying Reverse Freeze");
    final res = await Api().usePowerUp(PowerUps.reverseFreezeTeam, "-999",
        points.value, -999, is_freezed.value);

    await Future.delayed(Duration(seconds: 1));
    toggleLoading(afterText: "Reverse Freeze Applied Successfully"); //idhar maybe

    Get.closeAllSnackbars();
    if (res["status"] == "1") {
      // "1"
      GenericUtil.fancySnack("Sucess", "Opponent Team Freezed Successfully");
      timeLeftForReversal.value = 999; //
    } else {
      GenericUtil.fancySnack("Failed", res["message"]);
    }
  }

  Future<void> becomeInvisible() async {

    toggleLoading(textToShow: "Applying Invisibility");
    Get.back();
    final res = await Api().usePowerUp(
        PowerUps.invisible, "-999", points.value, -999, is_freezed.value);

    await Future.delayed(Duration(seconds: 1));
    toggleLoading(afterText: "Invisibility Applied Successfully");
    Get.closeAllSnackbars();
    if (res["status"] == "1") {
      GenericUtil.fancySnack("Successfully Applied Power Card",
          "You will be invisible for the next 7.5 minutes");
      // everything should have a countdown
    } else {
      GenericUtil.fancySnack("Failed to use Invisibility", res["message"]);
    }
  }
}

// GenericUtil.fancySnack(
// "Requesting very important data...",
// "",
// duration: 60.seconds, // it could be any reasonable time, but I set it lo-o-ong
// snackPosition: SnackPosition.BOTTOM,
// showProgressIndicator: true,
// isDismissible: true,
// backgroundColor: Colors.lightGreen,
// colorText: Colors.white,
// mainButton: TextButton(
// onPressed: Get.back,
// child: const Text(
// "Close"
// )));
// );4

// try this
