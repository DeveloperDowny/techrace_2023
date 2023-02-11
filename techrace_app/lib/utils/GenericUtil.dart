import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:techrace/api/api.dart';
import 'package:techrace/pages/login_screen.dart';
import 'package:techrace/utils/MStyles.dart';

class GenericUtil {

  static void fancySnack(title, message) {
    Get.snackbar(title, message,
        backgroundColor: MStyles.pColor, duration: Duration(seconds: 5));
  }
  static dynamic logout() async {
    Get.dialog(Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(

          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          // width: ScreenUtil().screenWidth * 0.8,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),

              // color: Colors.white
              color: MStyles.lightBgColor

          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

            (Text("Logging Out", style: MStyles.mTextStyle.copyWith(color: Colors.white.withOpacity(0.8)),)),
            SizedBox(width: 32),
            CircularProgressIndicator()
          ],),
        ),
      ),
    ));
    // return; //temp //should be commented in production
    final poits = await Geolocator
        .getCurrentPosition(); // this should do the thing
    var res = await Api().logout(logout_loc_lat: poits.latitude,logout_loc_lng: poits.longitude);
    await Future.delayed(Duration(seconds: 1));
    Get.back();
    if (res["status"] == "1") {
      Get.off(() => LoginScreen());
    } else {
      Get.closeAllSnackbars();
      GenericUtil.fancySnack("Log Out Failed", res["message"]);
    }
  }

  static Widget beveledParent(double rad2, {Widget? child, String? text}) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      // margin: EdgeInsets.only(top: 100, bottom: 32),
      // margin: EdgeInsets.only(top: 60, bottom: 16),
      child: Material(
        shadowColor: Color(0xff2e92da),
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(rad2),
              bottomLeft: Radius.circular(rad2),
              topRight: Radius.circular(rad2),
              topLeft: Radius.circular(rad2)),
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Color(0xff2e92da), border: Border(bottom: BorderSide())),
          child: child != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            // padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: child,
          ): Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Text(
              text!,
              style: MStyles.mTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}
