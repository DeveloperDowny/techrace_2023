import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

// import 'package:techrace/utils/timer.dart';
DateTime time = DateTime.now();

class TimeStream {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference ref;
  late Stream<DatabaseEvent> stream;
  late StreamSubscription<DatabaseEvent> sub1;
  TimeStream(){
    ref = FirebaseDatabase.instance.ref("/start_datetime");
    stream = ref.onValue;
    sub1 = stream.listen((DatabaseEvent event) {
      // print(event.snapshot.value);
      time = DateTime.parse(event.snapshot.value as String);
      //print("Time: $time");
    });
  }
}

