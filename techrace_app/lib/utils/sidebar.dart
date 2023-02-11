import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/client/hosting.dart';
import 'package:techrace/components/powerup_durations.dart';
import 'package:techrace/utils/MStyles.dart';
import 'package:techrace/utils/contactus.dart';
import 'package:techrace/utils/leaderboard.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  // bool isExpanded = false;
  var isExpanded = ValueNotifier(false);
  @override
  void initState() {
    //hosting test
    // await fetchLocations();
    //hosting test
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutSine);
    // CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: ValueListenableBuilder(
            valueListenable: isExpanded,
            builder: (context, value, child) {
              return (isExpanded.value)
                  ? SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.vertical,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(255, 39, 34, 34),
                                  width: 2),
                              // color: const Color.fromARGB(255, 179, 207, 226)
                              //     .withOpacity(0.5)
                              color: MStyles.pColorWithTransparency,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  // splashColor: Colors.white, //do this for every icon button
                                  onPressed: () {
                                    showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: ((context) =>
                                            const LeaderBoard()));
                                  },
                                  icon: const Icon(Icons.leaderboard_rounded),
                                ),
                                IconButton(
                                  // just for symmenter
                                  onPressed: () {
                                    showGeneralDialog(
                                      barrierDismissible: true,
                                      barrierLabel: '',
                                      context: context,
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Contact(),
                                    );
                                  },
                                  icon: const Icon(Icons.info_rounded),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // showDialog(
                                    //     context: context,
                                    //     builder: ((context) =>
                                    //         const LocTest()));
                                    // debugPrint("show powerups menu");
                                    //show powerup menu
                                    showDialog(
                                        useSafeArea: false,
                                        context: context,
                                        builder: (context) => PowerUpDialog());
                                  },
                                  icon: const Icon(Icons.bolt_rounded),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        useSafeArea: false,
                                        barrierDismissible: true,
                                        context: context,
                                        builder: ((context) =>
                                            // const LeaderBoard()
                                            PowerUpDurations()));
                                  },
                                  icon: const Icon(Icons.timer_rounded),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await controller.reverse();
                                    isExpanded.value = false;
                                  },
                                  icon: const Icon(Icons.cancel_outlined),
                                ),
                                // IconButton(
                                //     onPressed: () {
                                //       final box = GetStorage();
                                //       debugPrint("teamid: ${box.read("token")}");
                                //       debugPrint("teamid: ${box.read("tid")}");
                                //     },
                                //     icon: Icon(Icons.text_snippet_outlined)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 39, 34, 34),
                                width: 2),

                            // color: const Color.fromARGB(255, 179, 207, 226)
                            //     .withOpacity(0.5)
                            color: MStyles.pColorWithTransparency,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.bolt_rounded),
                          ),
                          //   color: Colors.white.withOpacity(.69),
                        ),
                        onTap: () {
                          isExpanded.value = true;

                          controller.forward();
                        },
                        onLongPress: () {
                          showDialog(
                            useSafeArea: false,

                            //this is the case
                            context: context,
                            builder: ((context) => PowerUpDialog()),
                          );
                          //show powerup menu
                          // debugPrint("show powerups menu");
                        },
                        onDoubleTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => const LeaderBoard());
                        },
                      ),
                    );
            }));
  }
}

// class LocTest extends StatefulWidget {
//   const LocTest({super.key});

//   @override
//   State<LocTest> createState() => LocTestState();
// }

// class LocTestState extends State<LocTest> {
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(32),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(
//             sigmaX: 10,
//             sigmaY: 10,
//           ),
//           child: Container(
//             height: 369,
//             decoration: BoxDecoration(
//               color: Colors.blueGrey.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(32),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(child: Container()),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(50, 6, 0, 0),
//                       child: Text('Location Test',
//                           style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 26)),
//                     ),
//                     Expanded(
//                       child: Container(),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 12.0, 12.0, 0),
//                       child: IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           icon: Icon(
//                             Icons.close_outlined,
//                             size: 32,
//                             color: Colors.white.withOpacity(0.8),
//                           )),
//                     )
//                   ],
//                 ),
//                 // Expanded(
//                 //   child: ListView.builder(
//                 //     physics: const BouncingScrollPhysics(),
//                 //     itemCount: Data.locData?["locations"].length,
//                 //     scrollDirection: Axis.vertical,
//                 //     itemBuilder: ((context, index) {
//                 //       return ListTile(
//                 //         title: Text(
//                 //           Data.locData?["names"][index],
//                 //           style: TextStyle(
//                 //               color: Colors.white.withOpacity(0.8),
//                 //               fontSize: 20),
//                 //         ),
//                 //         subtitle: Text(
//                 //           "${Data.locData!["locations"][index][0]}, ${Data.locData!["locations"][index][1]}",
//                 //           style: TextStyle(
//                 //               color: Colors.white.withOpacity(0.8),
//                 //               fontSize: 16),
//                 //         ),
//                 //       );
//                 //     }),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
