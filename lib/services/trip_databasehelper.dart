import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip.dart';

class TripDatabasehelper {
  CollectionReference<Map<String, dynamic>> _userTripsCollection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('trips');
  }

  Future<void> addTrip(Map<String, dynamic> tripData) async {
    try {
      await _userTripsCollection().add(tripData);
    } catch (e) {
      print('Error adding trip: $e');
    }
  }

  Future<void> updateTrip(String tripId, Map<String, dynamic> updatedData) async {
    try {
      await _userTripsCollection().doc(tripId).update(updatedData);
    } catch (e) {
      print('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _userTripsCollection().doc(tripId).delete();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  Stream<List<Trip>> getTrips() {
    return _userTripsCollection().snapshots().map(
          (snap) => snap.docs
              .map((d) => Trip.fromMap(d.data(), d.id))
              .toList(),
        );
  }
}