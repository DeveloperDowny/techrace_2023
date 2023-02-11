import 'package:get/get.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/home.dart';
import 'package:techrace/model/StateModel.dart';
import 'package:techrace/pages/waiting_screen.dart';
import 'package:techrace/utils/GameStates.dart';



// a1.
// At this point, I should be listening to the realtime database to be listening
// for my status.
// 1st state will be waiting_for_reg
// 2nd state will be waiting_for_game_start // this page should show the countdown
// timer
// 3rd state will be playing

class StateController extends GetxController {
  final currentState = GameStates.WaitingForReg.name.obs;
  // final stateModel = StateModel(currentState);
  late StateModel stateModel;

  StateController() {
    stateModel = StateModel(currentState);
    currentState.listen((currState) {

      switch (currState) {
        case  "WaitingForGameStart": {
          Get.off(() =>WaitingScreen());
          break;
        }

        case "Playing": {
          Get.off(() =>Home());
          break;
        }
      }

      // if (p0 == GameStates.WaitingForGameStart.name) {
      //   Get.to(() => LoginScreen());
      // }
    });
  }

  @override
  void dispose() {
    print("here");
    stateModel.sub1.cancel();
    // gameModel.sub1.cancel();
    super.dispose();
  }

}