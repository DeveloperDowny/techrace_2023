import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MStyles {
  static final mTextStyle = TextStyle(fontSize: 18.w, fontWeight: FontWeight.w700);
  static final pColor = Color(0xff2e92da);
  static final materialColor = Color(0xff121826);
  static final darkBgColor = Color(0xff010511);
  static final lightBgColor = Color(0xff070E1A);
  static final col3 = Color(0xcc2e92da);
  static final col4 = Color(0xff222257);
  static final col5 = Color(0xff000512);

  static final pColorWithTransparency  = Color(0xcc2e92da);


  static ElevatedButton buildElevatedButton(Function func, String text) {
    return ElevatedButton(
        onPressed: () => func(),
        child: Text(text, style: TextStyle(fontSize: 18.w, fontWeight: FontWeight.w700)),
        clipBehavior: Clip.antiAlias,
        style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(50),
            shape: BeveledRectangleBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(10.w))))
    );
  }

}