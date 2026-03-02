import 'dart:convert';
import 'package:flutter/material.dart';
import '../../auth/services/auth_api.dart';
import '../services/device_api.dart';

class DeviceController {

  // ================= ADD DEVICE =================
  static Future<bool> addDevice({
    required BuildContext context,
    required String deviceId,
    required String verificationCode,
    required String brand,
    required String model,
    required String color,
    required String licensePlate,
  }) async {
    try {
      print("========== ADD DEVICE START ==========");

      final authApi = AuthApi();
      final idToken = await authApi.getToken();

      if (idToken == null) {
        print("❌ TOKEN NOT FOUND");
        throw Exception("User not logged in");
      }

      print("🔥 TOKEN LENGTH: ${idToken.length}");

      final response = await DeviceApi.addVehicle(
        idToken: idToken,
        deviceId: deviceId,
        verificationCode: verificationCode,
        brand: brand,
        model: model,
        color: color,
        licensePlate: licensePlate,
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Device added successfully"),
            backgroundColor: Colors.green,
          ),
        );

        return true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );

      return false;

    } catch (e) {
      print("❌ EXCEPTION: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Exception: $e"),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }

  // ================= FETCH DEVICES =================
static Future<List<Map<String, dynamic>>> fetchDevices() async {
  try {
    final authApi = AuthApi();
    final idToken = await authApi.getToken();

    if (idToken == null) {
      throw Exception("User not logged in");
    }

    final response = await DeviceApi.getDevices(idToken: idToken);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List data = decoded["data"];

      List<Map<String, dynamic>> devices =
          data.map((e) => Map<String, dynamic>.from(e)).toList();

      /// 🔥 CONVERT antiThief VỀ BOOL CHUẨN NGAY TẠI ĐÂY
      for (var device in devices) {
        final raw = device["antiThief"];

        device["antiThief"] =
            raw == true || raw == 1 || raw == "true";
      }

      return devices;
    }

    throw Exception("Failed to fetch devices");
  } catch (e) {
    print("❌ FETCH ERROR: $e");
    return [];
  }
}
}