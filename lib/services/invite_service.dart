import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip_invite.dart';

class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    return user.uid;
  }

  Future<String> getUsernameByUid(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      final data = userDoc.data()!;

      if (data['username'] != null &&
          data['username'].toString().trim().isNotEmpty) {
        return data['username'].toString();
      }

      if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
        return data['name'].toString();
      }

      if (data['email'] != null && data['email'].toString().trim().isNotEmpty) {
        return data['email'].toString();
      }
    }

    return 'Someone';
  }

  Future<void> createAppNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createTripInvites({
    required String tripId,
    required String tripName,
    required String invitedByUid,
    required String invitedByUsername,
    required List<String> invitedUserIds,
  }) async {
    for (final invitedUserId in invitedUserIds) {
      final invitedUsername = await getUsernameByUid(invitedUserId);

      await _firestore
          .collection('users')
          .doc(invitedUserId)
          .collection('invites')
          .add({
        'tripId': tripId,
        'tripName': tripName,
        'invitedByUid': invitedByUid,
        'invitedByUsername': invitedByUsername,
        'invitedUserId': invitedUserId,
        'invitedUsername': invitedUsername,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await createAppNotification(
        userId: invitedUserId,
        title: 'Trip Request',
        body: '$invitedByUsername sent you a trip request',
      );
    }
  }

  Stream<List<TripInvite>> getPendingInvitesForCurrentUser() {
    final uid = currentUid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('invites')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TripInvite.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  Future<void> acceptInvite(TripInvite invite) async {
    final currentUserId = currentUid;
    final currentUsername = await getUsernameByUid(currentUserId);

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('invites')
        .doc(invite.id)
        .update({
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('trips').doc(invite.tripId).update({
      'memberIds': FieldValue.arrayUnion([currentUserId]),
    });

    await createAppNotification(
      userId: invite.invitedByUid,
      title: 'Trip Request',
      body: '$currentUsername accepted your request',
    );
  }

  Future<void> declineInvite(TripInvite invite) async {
    final currentUserId = currentUid;
    final currentUsername = await getUsernameByUid(currentUserId);

    print('Declining invite...');
    print('Invite id: ${invite.id}');
    print('Trip id: ${invite.tripId}');
    print('Current user id: $currentUserId');
    print('Original sender id: ${invite.invitedByUid}');
    print('Current username: $currentUsername');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('invites')
        .doc(invite.id)
        .update({
      'status': 'declined',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await createAppNotification(
      userId: invite.invitedByUid,
      title: 'Trip Request',
      body: '$currentUsername did not accept your request',
    );
  }
}