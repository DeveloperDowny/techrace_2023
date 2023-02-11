import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:techracev/main.dart';
//import 'package:techracev/utils/datetime.dart';

import 'utils/timestream.dart';
import 'package:qrscan/qrscan.dart' as scanner;

//ValueNotifier<List<Beacon>> beaconsFound = ValueNotifier<List<Beacon>>([]);
// List<Region> regions = <Region>[Region(identifier: 'techRace')];

class Validate extends StatefulWidget {
  const Validate({super.key});

  @override
  State<Validate> createState() => _ValidateState();
}

class _ValidateState extends State<Validate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Region> regions = <Region>[
    Region(identifier: 'techRace$clueNo')
  ]; //set region to current clue i.e techRace1, techRace2, techRace3.., techRacen

  List teamCodes = [];
  //consits of list of team codes who have timed out or fronzen
  ValueNotifier<int> listLength = ValueNotifier(0);

  //debug beacons
  ValueNotifier<String> debugResult = ValueNotifier<String>('');

  ValueNotifier<bool> validating = ValueNotifier(true);

  late StreamSubscription rangingStream;
  List teamCodesCompleted = []; //updated successfully goes here
  List dontcheckTeams = []; //invalid teams go here (if not in teams rtdb)

  ScaffoldFeatureController showStatus(
      BuildContext context, String updateCheck, String tCode) {
    if (updateCheck[0] == 'U') {
      teamCodesCompleted.add(tCode);
    } else if (updateCheck[0] == 'F' || updateCheck[0] == 'T') {
      teamCodes.add(tCode);
      listLength.value++;
    } else {
      // updateCheck[0] == 'E' || updateCheck[0] == 'C'
      dontcheckTeams.add(
          tCode); //add to the list if team code is invalid or at the wrong clue
    }

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueGrey.withOpacity(0.2),
        content: Text(updateCheck,
            style: const TextStyle(
              color: Colors.white,
            )),
        margin: EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        //padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
    //_controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    super.dispose();
    rangingStream.cancel();
    debugResult.dispose();
    validating.dispose();
    listLength.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //reference to firebase database
    // DatabaseReference ref = FirebaseDatabase.instance.ref('teams');
    // String firebaseTeams = 'dummy_teams';
    String firebaseTeams = fbChild;
    DatabaseReference ref = FirebaseDatabase.instance.ref(firebaseTeams);

    //stream to listen to beacons
    rangingStream = flutterBeacon.ranging(regions).listen(
      (RangingResult result) async {
        // result contains a region and list of beacons found
        // list can be empty if no matching beacons were found in range

        // debugPrint("Result: $result");
        debugResult.value = result.toString();

        if (result.beacons.isNotEmpty) {
          // beaconsFound.value = result.beacons;
          for (var element in result.beacons) {
            late String tCode;
            int tCodeInt = int.parse(
                element.proximityUUID.substring(33)); //last 3 digits of uuid
            if (tCodeInt < 10) {
              tCode = '00$tCodeInt';
            } else if (tCodeInt < 100) {
              tCode = '0$tCodeInt';
            } else {
              tCode = '$tCodeInt';
            }
            //debugPrint("testing $tCode");
            if (!teamCodes.contains(tCode) &&
                !teamCodesCompleted.contains(tCode) &&
                !dontcheckTeams.contains(tCode)) {
              //perfrom validation here itself
              String updateCheck = await updateDB(ref, tCode)
                  .timeout(const Duration(seconds: 10), onTimeout: () {
                return 'Timeout';
              });
              if (!mounted) return;
              showStatus(context, updateCheck, tCode);
            }
          }
        }
      },
    );

    //stream to listen to beacons

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validate'),
        centerTitle: true,
        actions: [
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Clue No. $clueNo'),
          ))
        ],
      ),
      body: Center(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                // style: ButtonStyle(
                //   backgroundColor:
                //       MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                // ),
                onPressed: () {
                  if (validating.value) {
                    rangingStream.pause();
                    validating.value = false;
                    _controller.reverse();
                  } else {
                    rangingStream.resume();
                    validating.value = true;
                    _controller.forward();
                  }
                },
                child: ValueListenableBuilder(
                  valueListenable: validating,
                  builder: ((context, value, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: _controller),
                        const SizedBox(width: 8),
                        (validating.value)
                            ? const Text('Pause Validation')
                            : const Text('Resume Validation'),
                      ],
                    );
                  }),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: validating,
                builder: (context, child, value) {
                  return (validating.value)
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextButton(
                              onPressed: () {
                                showGeneralDialog(
                                  barrierDismissible: true,
                                  barrierLabel: 'Debug',
                                  context: context,
                                  pageBuilder: ((context, animation,
                                      secondaryAnimation) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      backgroundColor:
                                          Colors.blueGrey.withOpacity(0.2),
                                      insetPadding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 0),
                                      title: const Text('Debug'),
                                      content: ValueListenableBuilder(
                                          valueListenable: debugResult,
                                          builder: (context, value, child) {
                                            return Text(debugResult.value);
                                          }),
                                    );
                                  }),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.bug_report),
                                  SizedBox(width: 8),
                                  Text('Debug'),
                                ],
                              )),
                        )
                      : Container();
                },
              ),
            ],
          ),

          //manual validation
          ManualValidation(
              ref: ref,
              mounted: mounted,
              teamCodesCompleted: teamCodesCompleted),
              //scan
          TextButton(
              onPressed: () async {
                String? qrRes = await scanner.scan();
                // debugPrint("TeamCode: $qrRes");
                String updateCheck = await updateDB(ref, qrRes as String)
                    .timeout(const Duration(seconds: 5), onTimeout: () {
                  return 'Timeout';
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.blueGrey.withOpacity(0.2),
                    content: Text(updateCheck,
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    margin: EdgeInsets.all(10),
                    behavior: SnackBarBehavior.floating,
                    //padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                if (updateCheck[0] == 'U') {
                  teamCodesCompleted.add(qrRes);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.qr_code_scanner),
                  SizedBox(width: 8),
                  Text('Scan'),
                ],
              )),
          //beacon validation
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: listLength,
                builder: (context, child, value) {
                  return ListView.builder(
                    itemCount: listLength.value,
                    itemBuilder: (context, index) {
                      ValueNotifier<bool> validating = ValueNotifier(false);
                      String updateCheck;
                      return Row(
                        children: [
                          Text(teamCodes[index]),
                          TextButton(
                            onPressed: () async {
                              validating.value = true;
                              updateCheck = await updateDB(ref, teamCodes[index])
                                  .timeout(const Duration(seconds: 5),
                                      onTimeout: () {
                                return 'Timeout';
                              });
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Colors.blueGrey.withOpacity(0.2),
                                  content: Text(updateCheck,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      )),
                                  margin: EdgeInsets.all(10),
                                  behavior: SnackBarBehavior.floating,
                                  //padding: const EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              if (updateCheck[0] == 'U') {
                                teamCodesCompleted.add(teamCodes[index]);
                                teamCodes.removeAt(index);
          
                                listLength.value--;
                              } else if (updateCheck[0] == 'E' ||
                                  updateCheck[0] == 'C') {
                                teamCodes.removeAt(index);
                                listLength.value--;
                              }
          
                              validating.value = false;
                            },
                            child: ValueListenableBuilder(
                                valueListenable: validating,
                                builder: (context, value, child) {
                                  return (!validating.value)
                                      ? const Text('Validate')
                                      : const CircularProgressIndicator
                                          .adaptive();
                                }),
                          ),
                        ],
                      );
                    },
                    shrinkWrap: true,
                  )
                      // : Container()
                      ;
                  // return (beaconsFound.value.isNotEmpty)
                  //     ? Text("${beaconsFound.value}")
                  //     : Container();
                }),
          ),
        ]),
      ),
    );
  }
}

class ManualValidation extends StatelessWidget {
  const ManualValidation({
    Key? key,
    required this.ref,
    required this.mounted,
    required this.teamCodesCompleted,
  }) : super(key: key);

  final DatabaseReference ref;
  final bool mounted;
  final List teamCodesCompleted;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      // style: ButtonStyle(
      //   backgroundColor:
      //       MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
      // ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              String teamCode = "0";

              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.blueGrey.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          teamCode = value;
                        },
                        decoration: const InputDecoration(
                            hintText: 'Team code',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16)),
                      ),
                      TextButton(
                        onPressed: () async {
                          String updateCheck = await updateDB(ref, teamCode)
                              .timeout(const Duration(seconds: 5),
                                  onTimeout: () {
                            return 'Timeout';
                          });
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.blueGrey.withOpacity(0.2),
                              content: Text(updateCheck,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                              margin: EdgeInsets.all(10),
                              behavior: SnackBarBehavior.floating,
                              //padding: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          if (updateCheck[0] == 'U') {
                            teamCodesCompleted.add(teamCode);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.edit),
          SizedBox(width: 8),
          Text('Manual Validation'),
        ],
      ),
    );
  }
}

// ScaffoldFeatureController showStatus (BuildContext context, String updateCheck, List teamCodesCompleted, String tCode, List teamCodes, ValueNotifier<int> listLength, List dontcheckTeams) {
//   if (updateCheck[0] == 'U') {
//                 teamCodesCompleted.add(tCode);
//               } else if (updateCheck[0] == 'F' || updateCheck[0] == 'T') {
//                 teamCodes.add(tCode);
//                 listLength.value++;
//               } else {
//                 // updateCheck[0] == 'E' || updateCheck[0] == 'C'
//                 dontcheckTeams.add(
//                     tCode); //add to the list if team code is invalid or at the wrong clue
//               }

//   return ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(updateCheck),
//     ),
//   );
// }

Future<String> updateDB(DatabaseReference ref, String teamCode) async {
  DatabaseReference teamRef = ref.child(teamCode); //team code reference

  int basePoints = 20;
  int validationCoolDown = 5; //minutes after which team can be validated again
  //get current points
  try {
    //get current time
    DateTime now = DateTime.now();

    final freezeTimeRef = await teamRef.child('freezed_on').once();
    final freezeTime = freezeTimeRef.snapshot.value as String;

    final freezeTimeParsed =
        DateTime.parse(freezeTime).add(const Duration(milliseconds: 450000));

    //if team if freezed don't validate until they're unfreezed
    if (freezeTimeParsed.isAfter(now)) {
      return 'Frozen';
    }

    final clueRef = await teamRef.child('current_clue_no').once();

    int clueNoCurr = clueRef.snapshot.value as int;
    // print("Points clue test:$clueNoCurr");
    if (clueNoCurr != clueNo) {
      //debugPrint('Clue to be solved is $clueNoCurr for $teamCode');
      return 'Clue to be solved is $clueNoCurr for $teamCode'; //team is at wrong clue, very highly unlikely
    }

    final pointsRef = await teamRef.child('balance').once();
    int points = pointsRef.snapshot.value as int;
    //print("Points test:$points");

    //calculate difference in time from prev clue time stamp or from game start time
    int differenceMin;

    if (clueNo == 1) {
      //if validating for clue 1
      differenceMin = now
          .difference(time)
          .inMinutes; //current_time - game_start_time (in minutes)
      //debugPrint("min_diff(1): $differenceMin");
    } else {
      final prevTimeRef =
          await ref.child('$teamCode/prev_clue_solved_timestamp').once();
      DateTime prevTime = DateTime.parse(prevTimeRef.snapshot.value as String);
      // print("prevtimestamp:$prevTime");
      differenceMin = now.difference(prevTime).inMinutes;
      if (differenceMin < validationCoolDown) {
        return 'Not enough time elapsed(5 mins)';
      }
      //debugPrint("min_diff: $differenceMin");
    }
    int pointsAwarded;
    pointsAwarded = 60 - differenceMin;
    pointsAwarded = pointsAwarded < 0 ? 0 : pointsAwarded;

    // }
    //choose a random number between 1 and 2
    int randomRoute = Random().nextInt(2) + 1;
    //could lead to many teams getting only one route after switch - outcome is unknown
    await ref.update({
      //update clue id = "clueNoRouteNo"
      "$teamCode/cid": "${clueNo + 1}$randomRoute",
      "$teamCode/balance":
          points + basePoints + pointsAwarded, //update points as per formula
      //base points are always awarded
      //points awarded are calculated based on time taken to solve the clue and can't be negative
      "$teamCode/current_clue_no": clueNo + 1, // increment clue number
      "$teamCode/prev_clue_solved_timestamp":
          now.toIso8601String(), //update timestamp to time of validation
      "$teamCode/hint_1": "-999", //reset hint1
      "$teamCode/hint_2": "-999", //reset hint2
    });
    //debugPrint('Updated');
    return 'Updated $teamCode'; //team updated to next clue successfully
  } catch (e) {
    //debugPrint("Update error(): $e"); //implies team doesn't exist
    return 'Error: Team does not exist';
  }
}

//possible cases while updation
//1. team if frozen ->
//2. team is at wrong clue
//3. team does not exist

//3. team is at correct clue
//4. team is at last clue (no consideration here)

// class DisplaySnackbar extends StatelessWidget {}

class DisplaySnackbar extends StatefulWidget {
  const DisplaySnackbar(
      {Key? key,
      required this.tCode,
      required this.updateCheck,
      required this.teamCodesCompleted,
      required this.teamCodes,
      required this.listLength,
      required this.dontcheckTeams})
      : super(key: key);
  final String updateCheck;
  //final BuildContext valcontext;
  final String tCode;
  final List teamCodesCompleted;
  final List teamCodes;
  final ValueNotifier listLength;
  final List dontcheckTeams;

  @override
  State<DisplaySnackbar> createState() => _DisplaySnackbarState();
}

class _DisplaySnackbarState extends State<DisplaySnackbar> {
  @override
  Widget build(BuildContext context) {
    //print('here');
    if (widget.updateCheck[0] == 'U') {
      widget.teamCodesCompleted.add(widget.tCode);
    } else if (widget.updateCheck[0] == 'F' || widget.updateCheck[0] == 'T') {
      widget.teamCodes.add(widget.tCode);
      widget.listLength.value++;
    } else {
      // updateCheck[0] == 'E' || updateCheck[0] == 'C'
      widget.dontcheckTeams.add(widget
          .tCode); //add to the list if team code is invalid or at the wrong clue
    }
    return SnackBar(
      content: Text('Status: ${widget.updateCheck}'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}