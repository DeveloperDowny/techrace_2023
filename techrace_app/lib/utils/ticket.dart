import 'dart:ui';

import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:techrace/api/api.dart';

import 'package:techrace/controllers/HomeController.dart';
import 'package:techrace/utils/AudioPlayer.dart';
import 'package:techrace/utils/carousel.dart';

import 'package:techrace/utils/locmeter.dart';
//qr
import 'package:qr_flutter/qr_flutter.dart';

import 'MLocalStorage.dart';
import 'MStyles.dart';

class GameTicket extends StatefulWidget {
  // final String clue;
  const GameTicket({
    super.key,
    // required this.clue
  });

  @override
  State<GameTicket> createState() => _GameTicketState();
}

class _GameTicketState extends State<GameTicket> {
  late String teamId;
  late String player1;
  late String player2;
  late int finalClueNo;
  // late DatabaseReference dbRef;

  // late Stream<DatabaseEvent> teamStream;
  // ValueNotifier<int> clueNo = ValueNotifier(0);
  // ValueNotifier<int> points = ValueNotifier(-1);
  // final homeController homeController = Get.put(homeController());

  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    teamId = box.read('tid');
    player1 = box.read('player1');
    player2 = box.read('player2') ?? '';
    //get final clue number
    finalClueNo = box.read('last_clue');
    // print('finalClueNo: $finalClueNo');

    // dbRef = FirebaseDatabase.instance.ref("/dummy_teams/$teamId");
    // // debugPrint("teamId: $teamId");
    // teamStream = dbRef.onValue;
  }

  @override
  Widget build(BuildContext context) {
    //stream to listen to changes in team data
    // teamStream.listen((DatabaseEvent event) {
    //   // print(event.snapshot.key);

    //   // debugPrint('event: ${event.snapshot.value}');
    //   Object? result = event.snapshot.value;
    //   if (result != null) {
    //     Map data = result as Map;
    //     clueNo.value = data['current_clue_no'];
    //     points.value = data['balance'];
    //   }

    //   // setState(() {});
    // });
    return Column(
      children: [
        //first ticket container (start)
        Ticket1(
          homeController: homeController,
          finalClueNo: finalClueNo,
        ),
        //second ticket container (middle)
        Ticket2(
            teamId: teamId,
            player1: player1,
            player2: player2,
            homeController: homeController),
        //third ticket container (last)
        Ticket3(teamId: teamId),
      ],
    );
  }
}

class Ticket3 extends StatelessWidget {
  const Ticket3({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const AllClip(cuts: 1),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: const BoxDecoration(
          color: ticketColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DottedLine(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 16.0, 0, 8),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        border: Border.all(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(16),
                        // backgroundBlendMode: BlendMode.color
                      ),
                      height: 150,
                      child: InkWell(
                          child: QRcode(teamId: teamId),
                          onTap: () => showGeneralDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionDuration:
                                    const Duration(milliseconds: 250),
                                barrierDismissible: true,
                                barrierLabel: '',
                                pageBuilder: (context, animation1, animation2) {
                                  return QRexpanded(teamId: teamId);
                                },
                              ))),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: containerColor,
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CarouselApp2();
                                    });
                              },
                              icon: Icon(
                                Icons.book_outlined,
                                color: Colors.white,
                                size: 35,
                              )),
                          Text(
                            'App Guide',
                            style: TextStyle(color: MStyles.pColor),
                          )
                        ],
                      )),
                )
              ],
            ),

            // const Spacer(),
          ],
        ),
      ),
    );
  }
}

const ticketColor = Color.fromARGB(126, 112, 128, 144);
const containerColor = Color.fromARGB(176, 1, 5, 17);
//rgba(143,127,112,1.000)

// const containerColor = Color.fromARGB(226, 143, 127, 112);

class Ticket2 extends StatelessWidget {
  const Ticket2({
    Key? key,
    required this.teamId,
    required this.player1,
    required this.player2,
    required this.homeController,
  }) : super(key: key);
  final String teamId;
  final String player1;
  final String player2;
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const AllClip(cuts: 0),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        color: ticketColor,
        // color: ticketColor,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DottedLine(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.green.withOpacity(0.2),
                  color: containerColor,
                  border: Border.all(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Team: ",
                          style: TextStyle(
                            // color: Colors.black,
                            color: MStyles.pColor,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(teamId,
                          style: const TextStyle(
                            // color: Colors.black,
                            // color: MStyles.pColor,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
              child: Container(
                // decoration: BoxDecoration(
                //   // color: Colors.green.withOpacity(0.2),
                //   border: Border.all(
                //     // color: Colors.blueGrey
                //     color: MStyles.pColor,
                //   ),
                //   borderRadius: BorderRadius.circular(16),
                // ),
                decoration: DottedDecoration(
                  color: MStyles.pColor,
                  borderRadius: BorderRadius.circular(16),
                  shape: Shape.box,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.green.withOpacity(0.2),
                          color: containerColor,
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(player1,
                                  style: const TextStyle(
                                      // color: Colors.black,

                                      )),
                              (player2 != "")
                                  ? const Text("&",
                                      style: TextStyle(
                                          // color: Colors.black,

                                          ))
                                  : const SizedBox(),
                              (player2 != "")
                                  ? Text(player2,
                                      style: const TextStyle(
                                          // color: Colors.black,

                                          ))
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                        color: Colors.blueGrey.withOpacity(0.8),
                        Icons.arrow_forward_outlined,
                        size: 36,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.green.withOpacity(0.2),
                          color: containerColor,
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Obx(
                                (() {
                                  String clue =
                                      homeController.clueData['clue'] ?? '';
                                  //print("clue: $clue");
                                  if (clue == '') {
                                    return const SizedBox();
                                  } else if (clue.substring(0, 4) != "Yay!" &&
                                      homeController.clueNo.value != 1) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'FROM',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: MStyles.pColor,
                                            // color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          " C${homeController.clueNo.value - 1}",
                                          style: const TextStyle(
                                            // color: Colors.black,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                }),
                              ),
                              Obx(
                                () => AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                          scale: animation, child: child),
                                  child: (speed.value <= 1.78)
                                      ? Icon(
                                          key: const ValueKey(0),
                                          Icons.directions_walk,
                                          color: Colors.white.withOpacity(0.5),
                                        )
                                      : (speed.value > 1.78 &&
                                              speed.value <= 3.79)
                                          ? Icon(
                                              key: const ValueKey(1),
                                              Icons.directions_run_rounded,
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                            )
                                          : (speed.value > 3.79 &&
                                                  speed.value < 11.11)
                                              ? Icon(
                                                  key: const ValueKey(2),
                                                  Icons
                                                      .electric_rickshaw_outlined,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                )
                                              : Icon(
                                                  key: const ValueKey(3),
                                                  Icons.train_outlined,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                ),
                                ),
                              ),
                              Obx(
                                () {
                                  String clue =
                                      homeController.clueData['clue'] ?? '';

                                  if (clue == '') {
                                    return const SizedBox();
                                  } else if (clue.substring(0, 4) != "Yay!") {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'TO',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: MStyles.pColor,
                                            // color: Colors.black
                                          ),
                                        ),
                                        Text(
                                          " C${homeController.clueNo.value}",
                                          style: const TextStyle(
                                            // color: Colors.black,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const DottedLine(),
          ],
        ),
      ),
    );
  }
}

class Ticket1 extends StatelessWidget {
  const Ticket1({
    Key? key,
    required this.homeController,
    required this.finalClueNo,
  }) : super(key: key);

  final HomeController homeController;
  final int finalClueNo;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const AllClip(cuts: 2),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        width: MediaQuery.of(context).size.width * 0.8,
        // height: MediaQuery.of(context).size.width * 0.3,
        decoration: const BoxDecoration(
          color: ticketColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                children: [
                  //Clue Container
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    // height: 200,
                    decoration: BoxDecoration(
                      color: containerColor,
                      // color: MStyles.pColor.withOpacity(0.5),
                      // color: Colors.amber.withOpacity(0.2),
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    //display clue from clue data
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "CLUE",
                            style: TextStyle(
                                // fontSize: 18,
                                color: MStyles.pColor,
                                // color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          Obx(() {
                            if (homeController.clueData["clue"] == "CLUE") {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            } else if (homeController.clueData["clue"] ==
                                null) {
                              // call if get clue api request doesn't go through
                              // return const SizedBox();
                              return TextButton(
                                  onPressed: () async {
                                    homeController.clueData.value = await Api()
                                        .getClueFromCid(homeController
                                            .clueNo.value
                                            .toString());
                                  },
                                  child: Text('Retry'));
                            } else if (homeController.clueData["clue_type"] ==
                                'i') {
                              return ImageExpanded(
                                  image: homeController.clueData['clue']);
                            } else if (homeController.clueData["clue_type"] ==
                                'a') {
                              return AudioPlayerWidget(
                                  audioUrl: homeController.clueData['clue']);
                            } else {
                              return Text(
                                "${homeController.clueData['clue']}",
                                style: TextStyle(
                                  //fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                  //     //hint1 container
                  Obx(() =>
                          //(hint1.value) ?
                          homeController.clueData["hint_1"] != "-999"
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                    // height: 200,
                                    decoration: BoxDecoration(
                                      // color: Colors.amber.withOpacity(0.2),
                                      color: containerColor,
                                      border:
                                          Border.all(color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    //display hint1 from clue data
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            "HINT 1",
                                            style: TextStyle(
                                                // fontSize: 18,
                                                // color: Colors.white,
                                                color: MStyles.pColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Obx(() {
                                            // print(
                                            //     "hint1: ${homeController.clueData["hint_1"]} hint1 type: ${homeController.clueData["hint_1_type"]}");
                                            if (homeController
                                                    .clueData["hint_1"] ==
                                                null) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: LoadingAnimationWidget
                                                    .staggeredDotsWave(
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              );
                                            }
                                            if (homeController
                                                    .clueData["hint_1_type"] ==
                                                'i') {
                                              return ImageExpanded(
                                                  image: homeController
                                                      .clueData['hint_1']);
                                            } else if (homeController
                                                    .clueData["hint_1_type"] ==
                                                'a') {
                                              return AudioPlayerWidget(
                                                  audioUrl: homeController
                                                      .clueData['hint_1']);
                                            } else {
                                              return Text(
                                                "${homeController.clueData['hint_1']}",
                                                style: TextStyle(
                                                  //fontSize: 18,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                              );
                                            }
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                      //: Container()

                      ),

                  // //hint2 container
                  Obx(() => (homeController.clueData["hint_2"] != "-999")
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            // height: 200,
                            decoration: BoxDecoration(
                              // color: Colors.amber.withOpacity(0.2),
                              color: containerColor,
                              border: Border.all(color: Colors.blueGrey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            //display hint2 from clue data
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "HINT 2",
                                    style: TextStyle(
                                        // fontSize: 18,
                                        // color: Colors.white,
                                        color: MStyles.pColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Obx(() {
                                    if (homeController.clueData["hint_1"] ==
                                        null) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: LoadingAnimationWidget
                                            .staggeredDotsWave(
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      );
                                    }
                                    if (homeController
                                            .clueData["hint_2_type"] ==
                                        'i') {
                                      return ImageExpanded(
                                          image: homeController
                                              .clueData['hint_2']);
                                    } else if (homeController
                                            .clueData["hint_2_type"] ==
                                        'a') {
                                      return AudioPlayerWidget(
                                          audioUrl: homeController
                                              .clueData['hint_2']);
                                    } else {
                                      return Text(
                                        "${homeController.clueData['hint_2']}",
                                        style: TextStyle(
                                          //fontSize: 18,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      );
                                    }
                                  }),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container()),
                  Obx((() {
                    //print("${homeController.clueNo.value}, $finalClueNo");
                    return ((homeController.clueData["hint_1"] == "-999" ||
                                homeController.clueData["hint_2"] == "-999") &&
                            homeController.clueNo.value != finalClueNo)
                        ? TextButton(
                            onPressed: () {
                              homeController.getHint();
                              // do get hint
                              //deduct points for hint (api), //display hint and also a track of the number of hints given
                              // print('get hint');
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                containerColor,
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  side:
                                      const BorderSide(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            child: Text(
                              "Get Hint",
                              style: TextStyle(
                                // color: Colors.white,
                                color: MStyles.pColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox();
                  })),
                ],
              ),
            ),
            const DottedLine(),
          ],
        ),
      ),
    );
  }
}

class ImageExpanded extends StatelessWidget {
  const ImageExpanded({
    Key? key,
    required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          // child: Image.network(
          //   image,
          //   loadingBuilder: (context, child, loadingProgress) {
          //     if (loadingProgress == null) return child;
          //     // return Center(
          //     //   child: LoadingAnimationWidget.stretchedDots(
          //     //       color: Colors.blue, size: 40),
          //     // );

          //     return Shimmer.fromColors(
          //         child: Container(
          //           color: Colors.blueGrey,
          //           height: 200,
          //         ),
          //         baseColor: Colors.white.withOpacity(0.5),
          //         highlightColor: Colors.black);
          //   },
          // ),

          child: FadeInImage(
            placeholderFit: BoxFit.scaleDown,
            // placeholderFilterQuality: FilterQuality.high,
            placeholder:
                Image.asset('assets/images/loading_infinity.webp').image,

            image: NetworkImage(image),
          ),
        ),
      ),
      onTap: () {
        showGeneralDialog(
            barrierDismissible: true,
            barrierLabel: '',
            context: context,
            pageBuilder: (context, a1, a2) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Center(
                          child:
                              InteractiveViewer(child: Image.network(image))),
                      Positioned.fill(
                          child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ))
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}

class QRexpanded extends StatefulWidget {
  const QRexpanded({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  final String teamId;

  @override
  State<QRexpanded> createState() => _QRexpandedState();
}

class _QRexpandedState extends State<QRexpanded> {
  late double brightness;
  @override
  void initState() {
    super.initState();
    // lastBright();
    DeviceDisplayBrightness.setBrightness(1);
    DeviceDisplayBrightness.keepOn(enabled: true);
  }

  void lastBright() async {
    brightness = await DeviceDisplayBrightness.getBrightness();
  }

  @override
  void dispose() {
    // DeviceDisplayBrightness.setBrightness(brightness);
    DeviceDisplayBrightness.resetBrightness();
    DeviceDisplayBrightness.keepOn(enabled: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          height: 300,
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: QRcode(teamId: widget.teamId),
          ),
        ),
      ),
    );
  }
}

class QRcode extends StatelessWidget {
  const QRcode({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return 
    // QrImage(
    //   // backgroundColor: Colors.white.withOpacity(0.5),
    //   errorCorrectionLevel: QrErrorCorrectLevel.M,
    //   data: teamId,
    //   version: QrVersions.auto,
    //   // size: 200.0,
    // );
    QrImageView(data: teamId, size: 200);
  }
}

//for the dotted line
class DottedLine extends StatelessWidget {
  const DottedLine({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          // direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            (constraints.constrainWidth() / 10).floor(),
            (index) => const SizedBox(
              height: 1.1,
              width: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.blueGrey),
              ),
            ),
          ),
        );
      },
    );
  }
}

//for clips in the ticket widget
class AllClip extends CustomClipper<Path> {
  final double radius = 16.0;
  final int cuts;

  const AllClip({required this.cuts});

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    if (cuts == 0) {
      path.addOval(
          Rect.fromCircle(center: Offset(0.0, size.height), radius: radius));
      path.addOval(Rect.fromCircle(
          center: Offset(size.width, size.height), radius: radius));
      path.addOval(
          Rect.fromCircle(center: const Offset(0.0, 0.0), radius: radius));
      path.addOval(
          Rect.fromCircle(center: Offset(size.width, 0.0), radius: radius));
    } else if (cuts == 1) {
      path.addOval(
          Rect.fromCircle(center: const Offset(0.0, 0.0), radius: radius));
      path.addOval(
          Rect.fromCircle(center: Offset(size.width, 0.0), radius: radius));
    } else if (cuts == 2) {
      path.addOval(
          Rect.fromCircle(center: Offset(0.0, size.height), radius: radius));
      path.addOval(Rect.fromCircle(
          center: Offset(size.width, size.height), radius: radius));
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
