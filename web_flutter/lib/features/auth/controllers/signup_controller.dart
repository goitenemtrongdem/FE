import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../config/api_config.dart';

class SignupController extends ChangeNotifier {

  bool loading = false;

  String? fcmToken;
  String? idToken;

  /* =========================
      STEP 1: SIGNUP
  ========================= */
  Future<void> signup({
    required String email,
    required String password,
  }) async {

    loading = true;
    notifyListeners();

    try {

      // 1️⃣ Get FCM
        // Nếu chưa có → lấy
  fcmToken ??= await FirebaseMessaging.instance.getToken();

  print("🔥 SIGNUP FCM = $fcmToken");

  if (fcmToken == null) {
    throw Exception("Cannot get FCM Token");
  }
      // 2️⃣ Call backend
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/signup-request"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("📡 SIGNUP STATUS = ${res.statusCode}");
      print("📦 SIGNUP BODY = ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw Exception(data["message"]);
      }

      final String customToken = data["customToken"];

      print("🔐 CUSTOM TOKEN = $customToken");

      // 3️⃣ Firebase login
      final userCred =
          await FirebaseAuth.instance.signInWithCustomToken(customToken);

      if (userCred.user == null) {
        throw Exception("Firebase login failed");
      }

      print("✅ LOGIN UID = ${userCred.user!.uid}");

      // 4️⃣ Get ID token (CACHE)
      idToken = await userCred.user!.getIdToken(true);

      print("🔥 ID TOKEN = $idToken");

    } catch (e) {

      print("❌ SIGNUP ERROR = $e");
      rethrow;

    } finally {

      loading = false;
      notifyListeners();

    }
  }

  /* =========================
      STEP 2: VERIFY + SAVE
  ========================= */
Future<void> verifyAndSave() async {

  // 🔄 Luôn lấy lại token mới nhất
  fcmToken ??= await FirebaseMessaging.instance.getToken();

  if (fcmToken == null) {
    throw Exception("Cannot get FCM Token");
  }

  // 🔄 Lấy user hiện tại
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  // 🔄 Lấy ID Token mới
  final idToken = await user.getIdToken(true);

  print("🟢 SEND FCM = $fcmToken");
print("🟢 SEND IDTOKEN = ${idToken!.substring(0, 20)}...");

  final res = await http.post(
    Uri.parse("${ApiConfig.baseUrl}/auth/after-verify"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "idToken": idToken,
      "fcmToken": fcmToken,
    }),
  );

  print("📡 VERIFY STATUS = ${res.statusCode}");
  print("📦 VERIFY BODY = ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Verify failed: ${res.body}");
  }
}
}