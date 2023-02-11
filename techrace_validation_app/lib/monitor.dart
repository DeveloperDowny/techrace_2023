// import 'package:flutter/material.dart';
// import 'package:flutter_beacon/flutter_beacon.dart';
// import 'dart:async';

// ValueNotifier<bool> monitoring = ValueNotifier(false);
// ValueNotifier<String> debugResult = ValueNotifier<String>('');
// ValueNotifier<List<Beacon>> beaconsFound = ValueNotifier<List<Beacon>>([]);
// List<Region> regions = <Region>[Region(identifier: 'techRace')];

// final StreamSubscription _rangingStream =
//     flutterBeacon.ranging(regions).listen((RangingResult result) {
//   // result contains a region and list of beacons found
//   // list can be empty if no matching beacons were found in range
//   debugPrint("Result: $result");
//   debugResult.value = result.toString();
//   beaconsFound.value = result.beacons;
// });

// class Monitor extends StatefulWidget {
//   const Monitor({super.key});

//   @override
//   State<Monitor> createState() => _MonitorState();
// }

// class _MonitorState extends State<Monitor> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Monitor'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             ValueListenableBuilder(
//               valueListenable: monitoring,
//               builder: (context, child, value) {
//                 return TextButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(
//                           Colors.white.withOpacity(0.2)),
//                     ),
//                     onPressed: () {
//                       if (monitoring.value) {
//                         _rangingStream.pause();
//                         monitoring.value = false;
//                       } else {
//                         _rangingStream.resume();
//                         monitoring.value = true;
//                       }
//                     },
//                     child: (monitoring.value)
//                         ? const Text('Stop Monitoring')
//                         : const Text('Start Monitoring'));
//               },
//             ),
//             ValueListenableBuilder(
//                 valueListenable: debugResult,
//                 builder: (context, child, value) {
//                   return (monitoring.value)
//                       ? Text(debugResult.value)
//                       : const SizedBox();
//                 }),
//             ValueListenableBuilder(
//                 valueListenable: beaconsFound,
//                 builder: (context, child, value) {
//                   return (monitoring.value)
//                       ? Text(beaconsFound.value.toString())
//                       : const SizedBox();
//                 }),
//           ],
//         ),
//       ),
//     );
//   }
// }
