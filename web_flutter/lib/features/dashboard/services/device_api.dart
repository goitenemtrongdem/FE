import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class DeviceApi {
   final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getNotifications(String userId) {
    return _db
        .collection("user-notifications")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
  static const String baseUrl = "http://localhost:3000/api";

  static Future<http.Response> addVehicle({
    required String idToken,
    required String deviceId,
    required String verificationCode,
    required String brand,
    required String model,
    required String color,
    required String licensePlate,
  }) async {
    final url = Uri.parse("$baseUrl/devices");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "deviceId": deviceId,
        "verificationCode": verificationCode,
        "brand": brand,
        "model": model,
        "color": color,
        "licensePlate": licensePlate,
      }),
    );

    return response;
  }

  // ================== GET DEVICES ==================
  static Future<http.Response> getDevices({
    required String idToken,
  }) async {
    final url = Uri.parse("$baseUrl/devices");

    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
    );
  }
}
String getUserIdFromToken(String token) {
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  return decodedToken["userId"]; 
}
