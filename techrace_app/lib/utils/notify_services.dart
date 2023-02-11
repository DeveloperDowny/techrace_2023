import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
    );
    const initializationSettings =
        InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    if (Platform.isAndroid) {
      print("requesting permission");
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    } else {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions();
    }
  }

  static Future showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String title,
      String body) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'default channel',
      'Game Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const DarwinNotificationDetails ios = DarwinNotificationDetails();
    const NotificationDetails platform =
        NotificationDetails(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }
}
