import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  Future<void> firebaseInit() async {
    await Firebase.initializeApp();
  }

  Future<String?> getTokenFirebase() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      // print('handleGetToken | getToken = $token');

      return token;
    } catch (e) {
      // Tangani kesalahan jika diperlukan
      print('Error: $e');
    }
  }
}
