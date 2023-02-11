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
