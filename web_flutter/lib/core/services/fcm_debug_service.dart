import 'package:firebase_messaging/firebase_messaging.dart';

class FcmDebugService {
  static Future<void> debugFCM() async {
    print("========== 🔍 FCM DEBUG START ==========");

    try {
      print("1️⃣ Requesting permission...");
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();

      print("✅ Permission status: ${settings.authorizationStatus}");

      print("2️⃣ Getting FCM token...");
      String? token = await FirebaseMessaging.instance
          .getToken(
            vapidKey: "BPAQH-UaL1Jb2_1BsaaRDMTQrxQu3sMHXxFI0p7WR18P9JaexK7o2TSps9lGknCzPUjL-pVvjq165Y2gSpPgf1A",
          )
          .timeout(const Duration(seconds: 5));

      print("✅ FCM TOKEN = $token");

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("🔁 TOKEN REFRESHED: $newToken");
      });

    } catch (e) {
      print("❌ FCM ERROR OCCURRED: $e");
    }

    print("========== 🔍 FCM DEBUG END ==========");
  }
}