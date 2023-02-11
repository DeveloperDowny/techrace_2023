import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:permission_handler/permission_handler.dart';

//global vars
bool nearbyPerms = false;
bool bl = false;
bool loc = false;
Future<void> checkPerms() async {
  try {
    //nearby check and request
    //scan permission check and request (required for monitoring beacons)
    PermissionStatus blScan = await Permission.bluetoothScan.request();
    //connect permission (required for checking whether bluetooth in on and if not then asking the user to enable it)
    PermissionStatus nearby = await Permission.bluetoothConnect.request();
    nearbyPerms = (nearby.isGranted && blScan.isGranted) ? true : false;
    BluetoothState bluetoothState = await flutterBeacon.bluetoothState;
    if (bluetoothState == BluetoothState.stateOff) {
      await flutterBeacon.openBluetoothSettings;
    }
    if (bluetoothState == BluetoothState.stateOn) {
      bl = true;
    }

    //camera perms
    // PermissionStatus camera = 
    await Permission.camera.request();

    //check if location if on, but doesn't work
    PermissionStatus locPerm = await Permission.location.request();
    if (locPerm.isGranted) {
      loc = true;
    }

    // flutterBeacon.checkLocationServicesIfEnabled.then((value) async {
    //   if (value) {
    //     loc = true;
    //   } else {
    //     const AndroidIntent intent = AndroidIntent(
    //       action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    //     );
    //     await intent.launch();
    //   }
    // });

    //USELESS (not functioning as expected)
    //location check and request
    // bool isLocationEnabled = await flutterBeacon.checkLocationServicesIfEnabled;
    // if (!isLocationEnabled) {
    //   // await flutterBeacon.requestAuthorization;
    //   PermissionStatus locPerm = await Permission.location.request();
    //   if (locPerm.isGranted) {
    //     loc = true;
    //   }
    // }
    // isLocationEnabled = await flutterBeacon.checkLocationServicesIfEnabled;
    // if (isLocationEnabled) {
    //   loc = true;
    // }

    //nearby devices permission
    if (nearbyPerms && bl && loc) {
      //debugPrint("All permissions granted");
    } else {
      //debugPrint("Permissions not granted");
    }
  } on PlatformException catch (e) {
    // library failed to initialize, check code and message
    //debugPrint("Perms Error: ${e.code}: ${e.message}");
  }
}
