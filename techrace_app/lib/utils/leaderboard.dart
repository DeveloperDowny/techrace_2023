import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//leaderboard shimmer effect
import 'package:shimmer/shimmer.dart';
import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/main.dart';
import 'package:techrace/utils/MLocalStorage.dart';
import 'package:techrace/utils/MStyles.dart';
import 'package:techrace/utils/PowerUps.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  //creating instance of database
  var search = ValueNotifier('');

  // Query databaseReference = FirebaseDatabase.instance.ref().child('teams') //temp
  Query databaseReference = FirebaseDatabase.instance
      .ref()
      .child(fbTeam) //team string
      .orderByChild('current_clue_no');

  // this should be a stream

  var rebuildLeaderBoard = ValueNotifier(false);

  final HomeController homeController = Get.find<HomeController>();

  // ValueNotifier<int> _myIndex = ValueNotifier(0);
  int rankIndex = 0;
  int finalClue = 0;
  final RxBool _isSorted = false.obs;
  Map leaderBoardData = {};

  //sort function to sort map
  Map sortMap(map) {
    List<MapEntry> entries = map.entries.toList();
    entries.sort((a, b) {
      // return a.value['current_clue_no'].compareTo(b.value['current_clue_no']);
      DateTime bTime = DateTime.parse(b.value["prev_clue_solved_timestamp"]);
      DateTime aTime = DateTime.parse(a.value["prev_clue_solved_timestamp"]);
      //compare time
      if (a.value["current_clue_no"] == b.value["current_clue_no"]) {
        // if same clue number, compare times else no need to compare time, decide by clue number
        if (bTime.compareTo(aTime) == 0) {
          // if same time compare balance, else no need to compare balance, decide by time
          return b.value["balance"] - a.value["balance"];
        } else {
          return aTime.compareTo(bTime);
        }
      } else {
        // decide by clue number when two teams in comparrision are at different clue numbers
        return b.value["current_clue_no"] - a.value["current_clue_no"];
      }
    });
    return Map.fromEntries(entries);
  }

  @override
  void initState() {
    super.initState();

    databaseReference.get().then((DataSnapshot snapshot) {
      // leaderBoardData = snapshot.value as Map;
      // debugPrint(snapshot.value.toString());

      leaderBoardData = snapshot.value as Map;
      // print("leaderBordData: $leaderBordData");
      leaderBoardData = sortMap(leaderBoardData);
      //find my rank using team id

      for (var i = 0; i < leaderBoardData.length; i++) {
        if (leaderBoardData.keys.elementAt(i) == MLocalStorage().getTeamID()) {
          rankIndex = i;
          break;
        }
      }
      final box = GetStorage();
      finalClue = box.read("last_clue");
      // print("finalClue: $finalClue");
      _isSorted.value = true;
    });
  }

  @override
  void dispose() {
    homeController.oppTid.value = "-999";
    // homeController.powerCard.value = PowerUps.blank;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          // height: 500,
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Obx(
                  () => Text(
                      homeController.powerCard.value == PowerUps.blank
                          ? "Leader Board"
                          : "Choose The Team To Use \n${powerUpMap[homeController.powerCard.value]["name"]} Power Card On"
                      // "leaderBoard", //if powercard is chosen say here to choose team to apply powercard to in red or blue
                      // "leaderBoard"
                      ,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 18)),
                ),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) => search.value = value,
                      scrollPadding: const EdgeInsets.all(0),
                      cursorColor: Colors.grey,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blueGrey.withOpacity(0.5),
                              width: 3),
                          gapPadding: 0,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(0),
                        hintText: 'Search (name or id)',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          // fontSize: 18,
                        ),
                        prefixIcon: Icon(
                          Icons.search_outlined,
                          color: Colors.blueGrey.withOpacity(0.8),
                          // size: 22,
                        ),
                        border: const OutlineInputBorder(
                          gapPadding: 0,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        // fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Obx(() => (_isSorted.value)
                    ? leaderBoardTile(
                        leaderBoardData.values.elementAt(rankIndex),
                        MLocalStorage().getTeamID(),
                        rankIndex)
                    : const SizedBox()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: Divider(
                    color: Colors.blueGrey.withOpacity(0.5),
                    thickness: 3,
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: search,
                    builder: (context, value, child) {
                      return Obx(() => (!_isSorted.value)
                          ? leaderBoardLoading()
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: leaderBoardData.length,
                              itemBuilder: (context, index) {
                                //print(leaderBoardData[index]);
                                bool isInvisible = leaderBoardData.values
                                    .elementAt(index)['is_invisible'];
                                String name1 = leaderBoardData.values
                                    .elementAt(index)['p1']
                                    .toString()
                                    .toLowerCase();
                                String name2 = leaderBoardData.values
                                    .elementAt(index)['p2']
                                    .toString()
                                    .toLowerCase();
                                String teamId =
                                    leaderBoardData.keys.elementAt(index);
                                // int currentClue = leaderBoardData.values
                                //     .elementAt(index)['current_clue_no'];
                                if (!isInvisible && index != rankIndex
                                    // && currentClue != finalClue
                                    ) {
                                  if (search.value != '') {
                                    if (name1.contains(
                                            search.value.toLowerCase()) ||
                                        name2.contains(
                                            search.value.toLowerCase()) ||
                                        teamId.toLowerCase().contains(
                                            search.value.toLowerCase())) {
                                      return leaderBoardTile(
                                          leaderBoardData.values
                                              .elementAt(index),
                                          leaderBoardData.keys
                                              .elementAt(index)
                                              .toString(),
                                          index);
                                    } else {
                                      return const SizedBox();
                                    }
                                  }
                                  return leaderBoardTile(
                                      leaderBoardData.values.elementAt(index),
                                      teamId,
                                      index);
                                }
                                return const SizedBox();
                              }));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget leaderBoardLoading() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return loadingTile();
      },
    );
  }

  Widget loadingTile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          //index container
          Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.black,
            child: Container(
              // height: 50,
              // width: 50,
              decoration: BoxDecoration(
                // color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '   ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          //team details container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey,
                highlightColor: Colors.black,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              ' ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey,
                          highlightColor: Colors.black,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(color: Colors.white),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  const Text(
                                    ' ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '           ',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget leaderBoardTile(Map data, String? teamId, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: () {
        if (teamId != null && teamId != MLocalStorage().getTeamID()) {
          homeController.oppTid.value = teamId;
          if (homeController.powerCard.value == PowerUps.blank) {
            showDialog(
                useSafeArea: false,
                context: context,
                barrierColor: Colors.transparent,
                builder: (BuildContext context) {
                  return PowerUpDialog(
                    onlyTeamPowerCards: true,
                  );
                });

            //     .then((value) {
            //   homeController.powerCard.value = PowerUps.blank;
            // });
          } else {
            homeController.applyPowerCard();
          }
        }
        // print(data);
        // print(teamId);
        //apply power up on certain team
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //index container
            Container(
              decoration: BoxDecoration(
                color: (rankIndex == index)
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.blueGrey.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${index + 1}.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            //team details container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: (rankIndex == index)
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.blueGrey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['p1'] +
                                  (data['p2'] != "" ? ' & ${data['p2']}' : ''),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              // '$teamId, Clue ${data['current_clue_no']}',
                              '$teamId, ' +
                                  ((data['current_clue_no'] == finalClue)
                                      ? "Finished Game"
                                      : "Clue ${data['current_clue_no']}"),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.2),
                            border: Border.all(color: Colors.white),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                Text(
                                  data['balance'].toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Points',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PowerUpDialog extends StatefulWidget {
  var onlyTeamPowerCards;

  PowerUpDialog({super.key, this.onlyTeamPowerCards = false});

  @override
  State<PowerUpDialog> createState() => _PowerUpDialogState();
}

class _PowerUpDialogState extends State<PowerUpDialog> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  void dispose() {
    // homeController.oppTid.value = "-999";
    homeController.powerCard.value = PowerUps.blank;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const rad = 25.0;
    const rad2 = 15.0;
    return BackdropFilter(
      filter: ImageFilter.blur(
          // sigmaX: 1.0, sigmaY: 1.0),
          // sigmaX: 3,
          // sigmaY: 3
          sigmaX: 3,
          sigmaY: 3),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Container(
            // margin: EdgeInsets.only(left: 10,right: 10,bottom: 10),
            height: double.maxFinite,
            //   height: ScreenUtil().screenHeight,
            //   height: ScreenUtil().screenHeight,
            width: double.maxFinite,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      // margin: EdgeInsets.only(top: 100, bottom: 32),
                      margin: EdgeInsets.only(top: 60, bottom: 16),
                      child: Material(
                        shadowColor: Color(0xff2e92da),
                        elevation: 10,
                        clipBehavior: Clip.antiAlias,
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(rad2),
                              bottomLeft: Radius.circular(rad2),
                              topRight: Radius.circular(rad2),
                              topLeft: Radius.circular(rad2)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xff2e92da),
                              border: Border(bottom: BorderSide())),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Choose Power Card to Apply",
                                  style: MStyles.mTextStyle,
                                ),
                                SizedBox(height: 8,),
                                Text(
                                  "Your Points:   ${homeController.points.value} TEC",
                                  style: MStyles.mTextStyle.copyWith(color: Colors.white.withOpacity(0.75), fontSize: 14.h),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: getPowerCards(
                                onlyTeamPowerCards: widget.onlyTeamPowerCards)),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    // padding: const EdgeInsets.only(right: 8.0, bottom: 35),
                    padding: const EdgeInsets.only(right: 8.0, bottom: 0),
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
                  ),
                )
              ],
            )),
      ),
    );
  }

  FlipCard buildFlipCard(double rad, PowerUps powerUp, String helpText,
      String powerCardName, int cost, dynamic icon) {
    final _controller = FlipCardController();
    return FlipCard(
      controller: _controller,
      flipOnTouch: false,
      front: Stack(
        children: [
          SizedBox(
            // height: 200.w,
            width: 200.w,
            // height: 150.w,
            height: 200.w,
            // width: 150.w,
            child: Material(
              shadowColor: Color(0xff2e92da),
              elevation: 10,
              clipBehavior: Clip.antiAlias,
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(rad),
                    bottomLeft: Radius.circular(rad),
                    topRight: Radius.circular(rad),
                    topLeft: Radius.circular(rad)),
              ),
              child: InkWell(
                //this is correct
                onTap: () async {
                  // showDialog(context: context, builder: builder)
                  homeController.powerCard.value = powerUp;
                  showPowerCardUseConfirmation(powerUp).then((value) => Get.back());


                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff2e92da),
                      border: Border(bottom: BorderSide())),
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        // "Freeze",
                        powerCardName,
                        style: MStyles.mTextStyle,
                      ),
                      // SizedBox(height: 8,),
                      // Expanded(child: Divider()),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Cost: $cost TEC")
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            // child: GestureDetector(
            //     onTap: () {
            //       _controller.toggleCard();
            //       print("here yoff");
            //     },
            //     child: Text(
            //       "?",
            //       style: MStyles.mTextStyle,
            //     )),
            child: CircleAvatar(
              // backgroundColor: Color(0xff312d8c),
              backgroundColor: Colors.transparent,
              radius: 20,
              child: IconButton(
                  // color: Colors.blue,
                  onPressed: () {
                    _controller.toggleCard();
                    print("here yoff");
                  },
                  icon: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 20,
                  )),
            ),
            top: 10,
            right: 10,
          )
        ],
      ),
      back: GestureDetector(
        onTap: () {
          _controller.toggleCard();
        },
        child: SizedBox(
          // height: 200.w,
          width: 200.w,
          // height: 150.w,
          height: 200.w,
          // width: 150.w,
          child: Material(
            shadowColor: Color(0xff2e92da),
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(rad),
                  bottomLeft: Radius.circular(rad),
                  topRight: Radius.circular(rad),
                  topLeft: Radius.circular(rad)),
            ),
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff2e92da),
                  border: Border(bottom: BorderSide())),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16),
                    child: Text(
                      helpText,
                      style: MStyles.mTextStyle.copyWith(
                          // fontSize: 10, fontWeight: FontWeight.normal),
                          fontSize: 11.5.w, fontWeight: FontWeight.normal),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showPowerCardUseConfirmation(PowerUps powerUp) async {
    await showDialog(
        context: context,
        builder: ((context) => Dialog(
          backgroundColor: Color(0xff121827),
          // backgroundColor: Theme.of(context).primaryColorDark,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Are you sure you want to use ${powerUpMap[homeController.powerCard.value]["name"]} Power Card?",
                  style: MStyles.mTextStyle,
                ),

                //, style: MStyles.mTextStyle,)


                // TextField(
                //   controller: homeController.guessedString,
                //   decoration: InputDecoration(
                //       border: OutlineInputBorder(),
                //       labelText: "Confirm",
                //       helperText:
                //       // "What's do you think is the location (name only not address)?\nE.g. The Taj Mahal Hotel",
                //       "",
                //       helperMaxLines: 10),
                // ),
                SizedBox(
                  height: 32,
                ),
                ElevatedButton(
                    onPressed: () {
                      homeController.powerCard.value = powerUp;
                      if (powerUp == PowerUps.guessLocation) {
                        homeController.guessedString.text = "";
                        guessLocDialog();
                        return;
                      } else if (powerUp == PowerUps.invisible) {
                        homeController.becomeInvisible();
                        return;
                      }

                      if (homeController.oppTid.value == "-999") {
                        showDialog(
                          // useSafeArea: false,
                            barrierDismissible: true,
                            context: context,
                            builder: ((context) => const LeaderBoard()));

                        // .then((value) {
                        //       homeController.oppTid.value = "-999";
                        //   // homeController.powerCard.value = PowerUps.blank;
                        //   // if (homeController.oppTid.value != "-999") {
                        //   //   Get.back();
                        //   // }
                        // });
                      } else {
                        // apply powercrd
                        homeController.applyPowerCard();
                      }

                      // homeController
                      //     .guessedLocationFunction(); //isme hi ye rakho
                    },
                    child: Text("CONTINUE",
                        style: TextStyle(
                            fontSize: 18.w, fontWeight: FontWeight.w700)),
                    clipBehavior: Clip.antiAlias,
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        shape: BeveledRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.w))))),
                SizedBox(
                  height: 16,
                ),

                ElevatedButton(
                    onPressed: () {
                      Get.back(); //isme hi ye rakho
                    },
                    child: Text("CANCEL",
                        style: TextStyle(
                            fontSize: 18.w, fontWeight: FontWeight.w700)),
                    clipBehavior: Clip.antiAlias,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size.fromHeight(50),
                        shape: BeveledRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.w)))))
              ],
            ),
          ),
        )));
  }

  void guessLocDialog() {
    showDialog(
        context: context,
        builder: ((context) => Dialog(
              backgroundColor: Color(0xff121827),
              // backgroundColor: Theme.of(context).primaryColorDark,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: homeController.guessedString,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Location Name",
                          helperText:
                              // "What's do you think is the location (name only not address)?\nE.g. The Taj Mahal Hotel",
                              "NOTE: Don't enter address. Only the name of the location you have guessed.\nExample1: The Taj Hotel\nExample 2: Galaxy Appartments",
                          helperMaxLines: 10),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await guessLocConfirmationDialog(context)
                              .then((value) => Get.back());
                          // homeController
                          //     .guessedLocationFunction();
                        },
                        child: Text("GUESS",
                            style: TextStyle(
                                fontSize: 18.w, fontWeight: FontWeight.w700)),
                        clipBehavior: Clip.antiAlias,
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(50),
                            shape: BeveledRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.w)))))
                  ],
                ),
              ),
            )));
  }

  Future<dynamic> guessLocConfirmationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: ((context) => Dialog(
              backgroundColor: Color(0xff121827),
              // backgroundColor: Theme.of(context).primaryColorDark,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Please confirm that your guess is '${homeController.guessedString.text}'",
                      style: MStyles.mTextStyle,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                        "Google the name once to make sure there is no spelling mistake.\n\nDon't put full address, only enter the name of the location.\n\nIf you think you made some typing mistake, click on 'CANCEL'")
                    //, style: MStyles.mTextStyle,)

                    ,
                    // TextField(
                    //   controller: homeController.guessedString,
                    //   decoration: InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       labelText: "Confirm",
                    //       helperText:
                    //       // "What's do you think is the location (name only not address)?\nE.g. The Taj Mahal Hotel",
                    //       "",
                    //       helperMaxLines: 10),
                    // ),
                    SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          homeController
                              .guessedLocationFunction(); //isme hi ye rakho
                        },
                        child: Text("CONFIRM & CONTINUE",
                            style: TextStyle(
                                fontSize: 18.w, fontWeight: FontWeight.w700)),
                        clipBehavior: Clip.antiAlias,
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(50),
                            shape: BeveledRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.w))))),
                    SizedBox(
                      height: 16,
                    ),

                    ElevatedButton(
                        onPressed: () {
                          Get.back(); //isme hi ye rakho
                        },
                        child: Text("CANCEL",
                            style: TextStyle(
                                fontSize: 18.w, fontWeight: FontWeight.w700)),
                        clipBehavior: Clip.antiAlias,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: Size.fromHeight(50),
                            shape: BeveledRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.w)))))
                  ],
                ),
              ),
            )));
  }

  getPowerCards({onlyTeamPowerCards = false}) {
    final powerCards = PowerUps.values;
    final l = <Widget>[];
    // final rad = 25.0;
    // final rad = 15.0;

    // powerCards.removeAt(0); // don't do this
    // for (PowerUps i in powerCards) {
    // l.add(Container(
    //   padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
    //   // margin: EdgeInsets.only(top: 100, bottom: 32),
    //   margin: EdgeInsets.only(top: 60, bottom: 16),
    //   child: Material(
    //     shadowColor: Color(0xff2e92da),
    //     elevation: 10,
    //     clipBehavior: Clip.antiAlias,
    //     shape: BeveledRectangleBorder(
    //       borderRadius: BorderRadius.only(
    //           bottomRight: Radius.circular(rad),
    //           bottomLeft: Radius.circular(rad),
    //           topRight: Radius.circular(rad),
    //           topLeft: Radius.circular(rad)),
    //     ),
    //     child: Container(
    //       decoration: BoxDecoration(
    //           color: Color(0xff2e92da),
    //           border: Border(bottom: BorderSide())),
    //       child: Column(
    //         // mainAxisSize: MainAxisSize.min,
    //         // crossAxisAlignment: CrossAxisAlignment.center,
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.symmetric(
    //                 horizontal: 16.0, vertical: 16),
    //             child: Text("Choose Power Card to Apply", style: MStyles.mTextStyle,),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // ));

    // l.add(Divider(thickness: 10, color: MStyles.pColor, endIndent: 80, indent: 80,));
    // l.add(Container(
    //     decoration: BoxDecoration(
    //         // color: Theme.of(context).primaryColor
    //         color: Colors.blue
    //
    //     ),
    //     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
    //     margin: EdgeInsets.only(top: 100, bottom: 32),
    //     child: Text("Choose Power Card to Apply", style: MStyles.mTextStyle,)));

    if (onlyTeamPowerCards) {
      for (int i = 2; i < powerCards.length - 2; i++) {
        l.add(buildFlipCard(
          25.0,
          powerCards[i],
          powerUpMap[powerCards[i]]["help"],
          powerUpMap[powerCards[i]]["name"],
          powerUpMap[powerCards[i]]["cost"],
          powerUpMap[powerCards[i]]["icon"],
        ));
        l.add(SizedBox(
          height: 16,
        ));
      }

      return l;
    }
    for (int i = 1; i < powerCards.length - 1; i++) {
      l.add(buildFlipCard(
        25.0,
        powerCards[i],
        powerUpMap[powerCards[i]]["help"],
        powerUpMap[powerCards[i]]["name"],
        powerUpMap[powerCards[i]]["cost"],
        powerUpMap[powerCards[i]]["icon"],
      ));
      l.add(SizedBox(
        height: 16,
      ));
    }

    return l;
  }
}

// class PowerUpDialog extends StatelessWidget {
//   const PowerUpDialog({
//     Key? key,
//   }) : super(key: key);
//
//
//
// }
