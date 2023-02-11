import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/utils/MStyles.dart';
import 'package:techrace/utils/ticket.dart';

import 'utils/timer.dart';

class GameSheet extends StatefulWidget {
  const GameSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<GameSheet> createState() => _GameSheetState();
}

class _GameSheetState extends State<GameSheet> {
  late String teamId;
  late int finalClueNo;
  // late DatabaseReference dbRef;
  // late Stream<DatabaseEvent> teamStream;
  // ValueNotifier<int> clueNo = ValueNotifier(0);
  // ValueNotifier<int> points = ValueNotifier(-1);
  // ValueNotifier<dynamic> clueData = ValueNotifier(HashMap.from({}));

  // final GameController gameController = Get.put(GameController());
  // final HomeController homeController = Get.put(HomeController());

  final HomeController homeController = Get.find<HomeController>();

  // @override
  // void dispose() {
  //   Get.delete<HomeController>();
  //   homeController.dispose(); //what about the reg screen wala part
  //   print(homeController.isClosed); //it is not closed
  //   super.dispose();
  // }

  // final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    teamId = box.read('tid');
    finalClueNo = box.read('last_clue');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .30,
      minChildSize: .159,
      maxChildSize: .83,
      builder: (BuildContext context, ScrollController scrollController) {
        const rad = 15.0;
        return Theme(
          data: ThemeData(
              // canvasColor: Colors.transparent,
              fontFamily: 'Inter',
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
              )
              // textTheme: TextTheme(color: Colors.white),
              ),
          child: Material(
            // color: const Color.fromARGB(255, 62, 85, 135).withOpacity(.69),
            color: Color.fromARGB(182, 1, 5, 17),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            //color: MStyles.pColor.withOpacity(.75),
            // color: const Color.fromARGB(255, 62, 85, 135).withOpacity(.69),
            // shape: BeveledRectangleBorder(
            //     borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(rad),
            //         topRight: Radius.circular(rad))),
            child: Padding(
              // padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints.tightFor(height: 0),
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(Icons.keyboard_arrow_up),
                      color: Colors.white,
                      iconSize: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            // color: Colors.white.withOpacity(0.4),
                            color: ticketColor,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            // child: Text("475 | C12"),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Obx(() => (homeController.points.value >=
                                              0)
                                          ? Text(
                                              "${homeController.points.value}")
                                          : const Text("")),
                                      // ValueListenableBuilder(
                                      //     valueListenable: points,
                                      //     builder: (context, value, child) {
                                      //       return (points.value >= 0)
                                      //           ? Text("${points.value}")
                                      //           : const Text("");
                                      //     }),
                                      Text("Points",
                                          style: TextStyle(
                                              fontSize: 9, color: Colors.blue)),
                                    ],
                                  ),
                                  // const SizedBox(width: 8),
                                  Obx(() {
                                    String clue =
                                        homeController.clueData["clue"] ?? '';
                                    // print("clue $clue");
                                    if (homeController.clueNo.value ==
                                            finalClueNo ||
                                        clue == 'CLUE') {
                                      return const SizedBox();
                                    } else
                                    // if (clue.substring(0, 4) != "Yay!")
                                    {
                                      return Row(
                                        children: [
                                          const VerticalDivider(
                                            color: Colors.blue,
                                            thickness: 1,
                                          ),

                                          // const SizedBox(width: 8),
                                          Column(
                                            children: [
                                              // Obx(() =>
                                              (homeController.clueNo.value != 0)
                                                  ? Text(
                                                      "${homeController.clueNo.value}")
                                                  : const Text(""),
                                              // ),
                                              Text("Clue",
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.blue)),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                    // else {
                                    //   return const SizedBox();
                                    // }
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          //   width: 50,
                          //   height: 50,
                          decoration: BoxDecoration(
                            // color: Colors.white.withOpacity(0.4),
                            color: ticketColor,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const TimerUp(),
                                Text("Time Elapsed",
                                    style: TextStyle(
                                        fontSize: 9, color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // const Ticket(),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GameTicket(),
                      // child: Obx(() => GameTicket(clue: gameController.clueData.value["clue"])),
                      // child: Obx(() => GameTicket(
                      //     clue: homeController.clueData["clue"] ?? "")),
                      // child: ValueListenableBuilder(
                      //     valueListenable: clueData,
                      //     builder: (context, value, child) {
                      //       return GameTicket(clue: clueData.value["clue"] ?? "");
                      //     }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
