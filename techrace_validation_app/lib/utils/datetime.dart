// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:datetime_setting/datetime_setting.dart';

Future<void> getDateSetting() async {
  bool timeAuto = await DatetimeSetting.timeIsAuto();
  bool timezoneAuto = await DatetimeSetting.timeZoneIsAuto();
  // print(timeAuto);
  // print(timezoneAuto);

  if (!timezoneAuto || !timeAuto) {
    DatetimeSetting.openSetting();
  }
}

// late DateTime time;
// Future<void> fetchTime() async {
//   String link = "https://dummy.web.app/time.json";
//   final response = await http.get(Uri.parse(link));
//   if (response.statusCode == 200) {
//     Map result = json.decode(response.body);
//     // Data.locData = result;
//     // print(result);
//     // print(result['startTime']);
//     // startDateTime.value = result['startTime'];
//     // print(DateTime.parse(startDateTime.value));
//     // var time = DateTime.now();
//     time = DateTime.parse(result['startTime']);
//     // var start = DateTime.parse(startDateTime.value);
//     // print("dtest: ${time.value}");
//     // //
//     // print("time dtest: $time");
//     // print("start dtest: $start");
//     // var diff = time.difference(start);
//     // print("dtest: ${diff}");
//     // print("dtest hrs: ${diff.inHours}");
//     // print("dtest mins: ${diff.inMinutes}");
//     // print("dtest secs: ${diff.inSeconds}");
//     // print(object)
//     // print(DateTime.now());
//     // dataFetched = true;
//   } else {
//     // dataFetched = false;
//     throw Exception('Failed to load locations');
//   }

//   // print(Data.locData?['names']);
//   // print(Data.locData?['locations']);
// }
