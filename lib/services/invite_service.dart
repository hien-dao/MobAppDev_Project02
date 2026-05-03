import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip_invite.dart';

class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _invitesCollection {
    return _firestore.collection('tripInvites');
  }

  CollectionReference<Map<String, dynamic>> get _tripsCollection {
    return _firestore.collection('trips');
  }

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    return user.uid;
  }

  Future<void> createTripInvites({
    required String tripId,
    required String tripName,
    required String invitedByUid,
    required String invitedByUsername,
    required List<String> invitedUserIds,
  }) async {
    final batch = _firestore.batch();
    bool hasWrites = false;

    for (final invitedUid in invitedUserIds) {
      if (invitedUid == invitedByUid) {
        continue;
      }

      final existingInvite = await _invitesCollection
          .where('tripId', isEqualTo: tripId)
          .where('invitedUid', isEqualTo: invitedUid)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingInvite.docs.isNotEmpty) {
        continue;
      }

      final inviteRef = _invitesCollection.doc();

      batch.set(inviteRef, {
        'tripId': tripId,
        'tripName': tripName,
        'invitedByUid': invitedByUid,
        'invitedByUsername': invitedByUsername,
        'invitedUid': invitedUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      hasWrites = true;
    }

    if (hasWrites) {
      await batch.commit();
    }
  }

  Stream<List<TripInvite>> getPendingInvitesForCurrentUser() {
    return _invitesCollection
        .where('invitedUid', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TripInvite.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> acceptInvite(TripInvite invite) async {
    final uid = currentUserId;

    final batch = _firestore.batch();

    final tripRef = _tripsCollection.doc(invite.tripId);
    final inviteRef = _invitesCollection.doc(invite.id);

    batch.update(tripRef, {
      'memberIds': FieldValue.arrayUnion([uid]),
    });

    batch.update(inviteRef, {
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> declineInvite(TripInvite invite) async {
    await _invitesCollection.doc(invite.id).update({
      'status': 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }
}
