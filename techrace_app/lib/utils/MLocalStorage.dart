import 'package:get_storage/get_storage.dart';

class MLocalStorage {
  static final MLocalStorage _instance = MLocalStorage._internal();
  static late final GetStorage box;
  static late final String tid;

  // using a factory is important
  // because it promises to return _an_ object of this type
  // but it doesn't promise to make a new one.
  factory MLocalStorage() {
    return _instance;
  }

  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  MLocalStorage._internal() {
    // initialization logic
    box = GetStorage();
    tid = getTeamID();
  }

  String getTeamID() {
    final tid = box.read("tid");
    return tid ?? "-999";
  }

  String getToken() {
    final tid = box.read("token");
    print(tid);
    return tid ?? "-999";
  }

  void writeToken(String t) {
    box.write("token", t);
  }

  void writeStartDateTime(String t) {
    box.write("start_date_time", t);
  }

  String getStartDateTime() {
    final startDateTime = box.read("start_date_time");
    return startDateTime ?? "-999";
  }

  void writeTid(String tid) {
    box.write("tid", tid);
  }

  void setBaseUrl(String t) {
    box.write("base_url", t);

    // temp below is working correctly
    // print("getBaseUrl()");
    // print(getBaseUrl());
    // print(getBaseUrl());
  }

  String getBaseUrl() {
    final startDateTime = box.read("base_url");
    return startDateTime ?? "-999";
  }

  void writeClueData(Map<String, dynamic> map) {
    box.write("clue_data", map);
  }

  Map<String, dynamic> getClueData() {
    return box.read("clue_data");
  }
}
