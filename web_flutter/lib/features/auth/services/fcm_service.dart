import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {

  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print("❌ FCM ERROR: $e");
      return null;
    }
  }

}