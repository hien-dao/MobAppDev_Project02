import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String tripId;
  final String inviteId;
  final bool read;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.tripId,
    required this.inviteId,
    required this.read,
    this.createdAt,
  });

  factory AppNotification.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return AppNotification(
      id: documentId,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      tripId: data['tripId'] ?? '',
      inviteId: data['inviteId'] ?? '',
      read: data['read'] ?? false,
      createdAt: data['createdAt'] == null
          ? null
          : (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
