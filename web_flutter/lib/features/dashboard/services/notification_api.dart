import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationApi {
  static const String baseUrl = "http://localhost:3000/api/notifications";

  // ================== REST API (GIỮ NGUYÊN) ==================
  static Future<List<NotificationModel>> fetchNotifications(String idToken) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      List list = body['data'];

      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  // ================== FIRESTORE REALTIME STREAM (THÊM) ==================
  static Stream<List<NotificationModel>> notificationStream(String userId) {
    return FirebaseFirestore.instance
        .collection("user-notifications")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
        });
  }

  // ================== MARK AS READ (THÊM) ==================
  static Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection("user-notifications")
        .doc(notificationId)
        .update({
      "isRead": true,
    });
  }

  // ================== DELETE NOTIFICATION (THÊM) ==================
  static Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection("user-notifications")
        .doc(notificationId)
        .delete();
  }

  // ================== CLEAR ALL USER NOTIFICATIONS (THÊM) ==================
  static Future<void> clearAll(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("user-notifications")
        .where("userId", isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}