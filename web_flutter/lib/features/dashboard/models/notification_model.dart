import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final int type;
  final bool isRead;
  final String deviceId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.deviceId,
    required this.createdAt,
  });

  // ================= FROM FIRESTORE (REALTIME) =================
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      title: data["title"] ?? "",
      content: data["content"] ?? "",
      type: data["type"] ?? 0,
      isRead: data["isRead"] ?? false,
      deviceId: data["deviceId"] ?? "",
      createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ================= FROM API JSON =================
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;

    if (json["createdAt"] is String) {
      createdAt = DateTime.parse(json["createdAt"]);
    } else if (json["createdAt"] is Timestamp) {
      createdAt = (json["createdAt"] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    return NotificationModel(
      id: json["id"].toString(),
      title: json["title"] ?? "",
      content: json["content"] ?? "",
      type: json["type"] ?? 0,
      isRead: json["isRead"] ?? false,
      deviceId: json["deviceId"] ?? "",
      createdAt: createdAt,
    );
  }

  // ================= TO JSON (OPTIONAL) =================
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "type": type,
      "isRead": isRead,
      "deviceId": deviceId,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}