import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"),
            // iOS: initializationSettingsIOS,
            macOS: null);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void createNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            'high_importance_channel', // id (ikutin yang ada di aplikasi_standart/android/app/src/main/AndroidManifest.xml)
            'high_importance_channel', // title
            // description:
            //     'This channel is used for important notifications.', // description
            importance: Importance.max,
            priority: Priority.high),
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        // payload: message.data['route']
      );
    } catch (e) {
      print("error dari fungsi createNotification() , ");
      print(e);
    }
  }
}
