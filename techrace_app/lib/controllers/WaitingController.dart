import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:get/get.dart';
import 'package:techrace/model/WaitingModel.dart';

class WaitingController extends GetxController {

  // final willStartAt = DateTime.fromMillisecondsSinceEpoch(1212);
  // final timeLeft = 60.obs;
  final timeLeft = (60*60*72).obs;
  final CountDownController controller = CountDownController();

  // final stateModel = StateModel(currentState);
  late WaitingModel waitModel;

  WaitingController() {
    waitModel = WaitingModel(timeLeft);
    timeLeft.listen((timeLeft) {
      // controller.restart(duration: timeLeft * 60);
      controller.restart(duration: timeLeft);
    });
  }

  @override
  void dispose() {
    print("here");
    waitModel.sub1.cancel();
    super.dispose();
  }
}
