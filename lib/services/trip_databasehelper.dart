import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip.dart';

class TripDatabaseHelper {
  final CollectionReference<Map<String, dynamic>> tripsCollection =
      FirebaseFirestore.instance.collection('trips');

  String get currentUserId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    return user.uid;
  }

  Future<String?> addTrip(Trip trip) async {
    try {
      final docRef = await tripsCollection.add(trip.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding trip: $e');
      return null;
    }
  }

  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    try {
      await tripsCollection.doc(tripId).update(data);
    } catch (e) {
      print('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await tripsCollection.doc(tripId).delete();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  Stream<List<Trip>> getUserTrips() {
    return tripsCollection
        .where('memberIds', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromMap(doc.data(), doc.id))
            .toList());
  }
}
