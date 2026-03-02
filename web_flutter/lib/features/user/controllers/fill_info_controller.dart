import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/api_config.dart';

class FillInfoController {

  Future<void> fillInfo({
    required String fullname,
    required String address,
    required String birthday,
    required String citizenNumber,
    required String phoneNumber,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final idToken = await user.getIdToken(true);

    if (idToken == null) {
      throw Exception("Cannot get idToken");
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/user/update-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",  // ✅ QUAN TRỌNG
      },
body: jsonEncode({
  "fullName": fullname,        // ✅ chữ N viết hoa
  "address": address,
  "dateOfBirth": birthday,     // ✅ đúng key backend
  "citizenNumber": citizenNumber,
  "phoneNumber": phoneNumber,  // ✅ đúng key backend
}),
    );

    print("📡 FILL INFO STATUS = ${response.statusCode}");
    print("📦 FILL INFO BODY = ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}