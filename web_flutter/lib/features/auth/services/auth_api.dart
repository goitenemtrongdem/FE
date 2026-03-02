// import '../../../core/network/api_client.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// class AuthApi {
//   static const String _apiKey =
//       'AIzaSyDicr5ZKJVqiIZhXOArU6NYesMmtnvZmKo';

//   /// 1️⃣ SIGN UP → LẤY idToken
//   Future<Map<String, dynamic>> signUp({
//     required String email,
//     required String password,
//   }) async {
//     final response = await ApiClient.post(
//       'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
//       {
//         "email": email,
//         "password": password,
//         "returnSecureToken": true,
//       },
//     );

//     return response;
//   }

//   /// 2️⃣ SEND VERIFY EMAIL
//   Future<void> sendVerifyEmail({
//     required String idToken,
//   }) async {
//     await ApiClient.post(
//       'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey',
//       {
//         "requestType": "VERIFY_EMAIL",
//         "idToken": idToken,
//       },
//     );
//   } 

// Future<bool> checkEmailVerified({
//   required String idToken,
// }) async  {
//   final res = await ApiClient.post(
//     'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey',
//     {
//       "idToken": idToken,
//     },
//   );

//   return res['users'][0]['emailVerified'] == true;
// }

//   /// 3️⃣ AFTER VERIFY → BACKEND NODEJS
//   static Future<void> afterVerify({
//     required String idToken,
//   }) async {
//     await ApiClient.post(
//       'http://localhost:3000/auth/after-verify',
//       {
//         "idToken": idToken,
//       },
//     );
//   }
//   // 4️⃣ SIGN IN -----------------------------------------------
//  final String baseUrl = "http://localhost:3000";
//   final FlutterSecureStorage storage = const FlutterSecureStorage();

//   /// LOGIN
//   Future<bool> signIn(String email, String password) async {

//     final response = await http.post(
//       Uri.parse("$baseUrl/auth/signin"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "email": email,
//         "password": password,
//       }),
//     );

//     print("📡 LOGIN STATUS: ${response.statusCode}");
//     print("📦 LOGIN BODY: ${response.body}");

//     if (response.statusCode == 200) {

//       final data = jsonDecode(response.body);

//       final idToken = data["data"]["idToken"];

//       if (idToken != null) {
//         await storage.write(key: "idToken", value: idToken);
//         print("✅ TOKEN SAVED");
//         return true;
//       }
//     }

//     return false;
//   }

//   /// LẤY TOKEN
//   Future<String?> getToken() async {
//     return await storage.read(key: "idToken");
//   }

//   /// LOGOUT
//   Future<void> logout() async {
//     await storage.delete(key: "idToken");
//   }

//    Future<void> updateFcm(String token, String accessToken) async {
//   try {
//     final response = await http
//         .post(
//           Uri.parse("$baseUrl/users/update-fcm"),
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $accessToken",
//           },
//           body: jsonEncode({
//             "fcmToken": token,
//           }),
//         )
//         .timeout(const Duration(seconds: 5));

//     print("UPDATE FCM STATUS: ${response.statusCode}");
//   } catch (e) {
//     print("UPDATE FCM ERROR: $e");
//   }
// }
// }


import '../../../core/network/api_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../config/api_config.dart';
class AuthApi {
  static const String _apiKey =
      'AIzaSyDicr5ZKJVqiIZhXOArU6NYesMmtnvZmKo';

  final String baseUrl = "http://localhost:3000";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// ================= SIGN UP =================
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
      {
        "email": email,
        "password": password,
        "returnSecureToken": true,
      },
    );

    return response;
  }

  /// ================= SEND VERIFY EMAIL =================
  Future<void> sendVerifyEmail({
    required String idToken,
  }) async {
    await ApiClient.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey',
      {
        "requestType": "VERIFY_EMAIL",
        "idToken": idToken,
      },
    );
  }

static Future afterVerify({
  required String idToken,
  required String fcmToken,
}) async {

  final res = await http.post(
    Uri.parse("${ApiConfig.baseUrl}/auth/after-verify"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $idToken",
    },
    body: jsonEncode({
      "fcmToken": fcmToken,
    }),
  );

  return jsonDecode(res.body);
}
  /// ================= CHECK EMAIL VERIFIED =================
  Future<bool> checkEmailVerified({
    required String idToken,
  }) async {
    final res = await ApiClient.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey',
      {
        "idToken": idToken,
      },
    );

    return res['users'][0]['emailVerified'] == true;
  }
  /// ================= SIGN IN =================
Future<Map<String, dynamic>> signIn(String email, String password) async {
  final response = await http.post(
    Uri.parse("$baseUrl/auth/signin"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  print("📡 LOGIN STATUS: ${response.statusCode}");
  print("📦 LOGIN BODY: ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    final firebaseCustomToken = data["firebaseCustomToken"];
    final idToken = data["idToken"];
    final userId = data["uid"];

    if (firebaseCustomToken == null) {
      throw Exception("firebaseCustomToken not found in response");
    }

    // 🔐 Lưu token backend (nếu cần)
    if (idToken != null) {
      await storage.write(key: "idToken", value: idToken);
    }

    if (userId != null) {
      await storage.write(key: "userId", value: userId);
    }

    print("✅ LOGIN DATA SAVED");

    return data; // ✅ trả full JSON cho controller
  } else {
    throw Exception("Login failed: ${response.body}");
  }
}

  /// ================= GET TOKEN =================
  Future<String?> getToken() async {
    return await storage.read(key: "idToken");
  }

  /// ================= GET USER ID =================
  Future<String?> getUserId() async {
    return await storage.read(key: "userId");
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await storage.delete(key: "idToken");
    await storage.delete(key: "userId");
  }

  /// ================= UPDATE FCM =================
  Future<void> updateFcm(String fcmToken, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/update-fcm"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          "fcmToken": fcmToken,
        }),
      ).timeout(const Duration(seconds: 5));

      print("UPDATE FCM STATUS: ${response.statusCode}");
    } catch (e) {
      print("UPDATE FCM ERROR: $e");
    }
  }
}