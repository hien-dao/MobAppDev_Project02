import 'package:cloud_firestore/cloud_firestore.dart';

class TripInvite {
  final String id;
  final String tripId;
  final String tripName;
  final String invitedByUid;
  final String invitedByUsername;
  final String invitedUid;
  final String status;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  TripInvite({
    required this.id,
    required this.tripId,
    required this.tripName,
    required this.invitedByUid,
    required this.invitedByUsername,
    required this.invitedUid,
    required this.status,
    this.createdAt,
    this.respondedAt,
  });

  factory TripInvite.fromMap(Map<String, dynamic> data, String documentId) {
    return TripInvite(
      id: documentId,
      tripId: data['tripId'] ?? '',
      tripName: data['tripName'] ?? '',
      invitedByUid: data['invitedByUid'] ?? '',
      invitedByUsername: data['invitedByUsername'] ?? '',
      invitedUid: data['invitedUid'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] == null
          ? null
          : (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] == null
          ? null
          : (data['respondedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'tripName': tripName,
      'invitedByUid': invitedByUid,
      'invitedByUsername': invitedByUsername,
      'invitedUid': invitedUid,
      'status': status,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'respondedAt': respondedAt == null
          ? null
          : Timestamp.fromDate(respondedAt!),
    };
  }
}
