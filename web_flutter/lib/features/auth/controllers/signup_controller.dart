import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool success = false;
  String message = '';

  Future<void> handleSignup() async {
    loading = true;
    message = '';
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/auth/signup-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      success = data['success'] == true;
      message = data['message'] ?? 'Unknown response';
    } catch (e) {
      success = false;
      message = 'Cannot connect to server';
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
