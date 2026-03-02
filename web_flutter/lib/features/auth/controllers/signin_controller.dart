import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_api.dart';

class SigninController extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool success = false;
  bool canNavigate = false;
  String message = '';

  Future<void> handleSignin() async {
    loading = true;
    message = '';
    success = false;
    canNavigate = false;
    notifyListeners();

    try {
      print("STEP 1: Calling backend signIn API");

      /// 1️⃣ Gọi backend login
      final data = await _authApi.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      ).timeout(const Duration(seconds: 10));

      print("STEP 2: Backend login success");

      final firebaseCustomToken = data['firebaseCustomToken'];

      if (firebaseCustomToken == null) {
        throw Exception("firebaseCustomToken is null");
      }

      print("STEP 3: Login Firebase with custom token");

      /// 2️⃣ Login Firebase bằng custom token
      await FirebaseAuth.instance.signInWithCustomToken(firebaseCustomToken);

      final firebaseUser = FirebaseAuth.instance.currentUser;
      print("🔥 CHECK FIREBASE USER = ${firebaseUser?.uid}");

      if (firebaseUser == null) {
        throw Exception("Firebase login failed");
      }

      /// 3️⃣ Lấy JWT token backend (nếu bạn lưu token)
      final token = await _authApi.getToken();
      if (token == null) {
        throw Exception("Token not found after login");
      }

      print("STEP 4: Token length = ${token.length}");

      // ================= FCM =================
      try {
        print("STEP 5: Requesting FCM permission");

        await FirebaseMessaging.instance.requestPermission()
            .timeout(const Duration(seconds: 5));

        print("STEP 6: Getting FCM token");

        final fcmToken = await FirebaseMessaging.instance.getToken(
          vapidKey: "BPAQH-UaL1Jb2_1BsaaRDMTQrxQu3sMHXxFI0p7WR18P9JaexK7o2TSps9lGknCzPUjL-pVvjq165Y2gSpPgf1A",
        ).timeout(const Duration(seconds: 5));

        print("STEP 7: FCM token = $fcmToken");

        if (fcmToken != null) {
          print("STEP 8: Updating FCM to backend");

          await _authApi.updateFcm(fcmToken, token)
              .timeout(const Duration(seconds: 5));

          print("STEP 9: updateFcm DONE");
        }
      } catch (fcmError) {
        print("FCM ERROR CAUGHT: $fcmError");
      }

      message = "Signin successful";
      success = true;
      canNavigate = true;
    } catch (e) {
      print("MAIN ERROR: $e");
      message = e.toString();
      success = false;
    }

    loading = false;
    notifyListeners();
  }
}