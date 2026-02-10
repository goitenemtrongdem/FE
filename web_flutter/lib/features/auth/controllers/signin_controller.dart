import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class SigninController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool success = false;
  bool canNavigate = false;
  String message = '';

  /// token backend trả về
  String? idToken;

  Future<void> handleSignin() async {
    loading = true;
    message = '';
    success = false;
    canNavigate = false;
    notifyListeners();

    try {
      /// 1️⃣ LẤY FCM TOKEN
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        throw Exception('Cannot get FCM token');
      }

      /// 2️⃣ CALL BACKEND SIGN IN
      final response = await http.post(
        Uri.parse('http://localhost:3000/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'fcmToken': fcmToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['message'] == 'Sign in successful') {
        success = true;
        message = data['message'];

        /// 3️⃣ LẤY ID TOKEN BACKEND SINH RA
        idToken = data['data']?['idToken'];

        canNavigate = true;
      } else {
        message = data['message'] ?? 'Sign in failed';
      }
    } catch (e) {
      message = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
