import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techrace/api/network_util.dart';
import 'package:techrace/utils/MLocalStorage.dart';
import 'package:techrace/utils/PowerUps.dart';

class Api {
  NetworkUtil _netUtil = new NetworkUtil();

  // static final BASE_URL = "http://10.0.2.2:5000";
  // static final BASE_URL = "http://10.0.2.2:5000";
  // static final BASE_URL = "http://64.227.146.54";
  // static final BASE_URL = "https://faf9-150-242-199-207.in.ngrok.io";
  static var BASE_URL = MLocalStorage().getBaseUrl();

  // static var BASE_URL = "https://bc0d-150-242-199-207.in.ngrok.io";
  // static var BASE_URL = "https://4008-150-242-199-207.in.ngrok.io";
  // take this from MLocalStorage

  // static final LOGIN_URL = BASE_URL + "/users/new_user";
  static final LOGIN_URL = BASE_URL + "/login";
  static final LOGOUT_URL = BASE_URL + "/users/logout";
  static final CHANGE_STATE_URL = BASE_URL + "/game" + "/change_state";
  static final GET_CLUE_FROM_CID = BASE_URL + "/game" + "/get_clue_from_cid";
  static final GET_NEXT_CLUE_URL = BASE_URL + "/game" + "/get_next_clue";
  static final POWERUPS_URL = BASE_URL + "/game" + "/powerups";
  static final GET_HINT = BASE_URL + "/game" + "/get_hint";
  var formData;

  // router.post("/get_next_clue", auth, getNextClue); v
  // router.post("/change_state", auth, changeState); v
  //
  // router.post("/powerups/:pid", auth, powerUps);
  // router.post("/get_hint_1", auth, getHint1);
  // router.post("/get_hint_2", auth, getHint1);
  // router.post("/get_clue_from_cid", auth, getClueFromCidFirestore);
  // router.post("/update_balance", auth, updateBalance);
  // router.post("/add_clue", auth, addClue);
  // router.post("/update_time", auth, updateTimeToStart);

  Future<dynamic> usePowerUp(PowerUps powerUp, String opp_tid,
      int current_balance, int ask_timestamp, bool isFreezed,
      [guessed_location]) {
    if (isFreezed && powerUp != PowerUps.reverseFreezeTeam) {
      return Future(() {
        return HashMap.from({
          "status": "0",
          "message":
              "You are Freezed. \nYou cannot use any Power Card till you are Unfreezed. "
        });
      });
    }

    // todo add internet checks (not here though)

    final askTimeStamp = DateTime.now().toString();
    formData = FormData.fromMap({
      "opp_tid": opp_tid,
      "current_balance": current_balance,
      // "ask_timestamp":ask_timestamp,
      "ask_timestamp": askTimeStamp,
      "guessed_location": guessed_location ?? "n/a"
    });
    return _netUtil
        .postf(POWERUPS_URL + "/${powerUp.index}", formData)
        .then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<dynamic> login(
      String teamId, String password, double curr_lat, double curr_lng) {
    formData = FormData.fromMap({
      "tid": teamId,
      "password": password,
      "curr_lat": curr_lat,
      "curr_lng": curr_lng
    });

    return _netUtil.post(LOGIN_URL, formData).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  // Future<dynamic> getClueFromCid(String cid) {
  Future<dynamic> getClueFromCid(String cid) {
    // randomly assign a route number. send route number too
    formData = FormData.fromMap({"cid": cid}); // directly set cid
    return _netUtil.postf(GET_CLUE_FROM_CID, formData).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  // TODO validation ke baad yeh hona chahiye
  Future<dynamic> getNextClue(int updatedBal, int newClueNo,
      int milisSinceEpochOfPrevClueSolveTimestamp) {
    formData = FormData.fromMap({
      "tid": "025",
      //this is entailed in bearer token
      "balance": updatedBal,
      "clue_no": newClueNo,
      "prev_clue_solved_timestamp": milisSinceEpochOfPrevClueSolveTimestamp
    });

    return _netUtil.postf(GET_NEXT_CLUE_URL, formData).then((dynamic res) {
      print(res.toString());

      // example response
      // {
      //   "status": "1",
      // "message": "Request completed successfully.",
      // "current_clue_no": 2,
      // "clue": "025_2"
      // }
      return res;
    });
  }

  Future<dynamic> logout({logout_loc_lat = "-999", logout_loc_lng = "-999"}) {
    return _netUtil
        .postf(
            LOGOUT_URL,
            FormData.fromMap({
              "logout_loc_lat": logout_loc_lat,
              "logout_loc_lng": logout_loc_lng
            }))
        .then((dynamic res) {
      print(res.toString());
      final box = GetStorage();
      box.erase();
      final tet = box.read("markers_stored");
      return res;
    });
  }

  Future<dynamic> changeStateToPlaying() {
    return _netUtil
        .postf(CHANGE_STATE_URL, FormData.fromMap({"new_state": "Playing"}))
        .then((dynamic res) {
      print(res.toString());
      final box = GetStorage();
      box.erase();
      return res;
    });
  }

  Future<dynamic> getHint(String cid, int updateBalance) {
    formData = FormData.fromMap({"cid": cid, "updated_balance": updateBalance});
    return _netUtil.postf(GET_HINT, formData).then((dynamic res) {
      return res;
    });
  }
}
