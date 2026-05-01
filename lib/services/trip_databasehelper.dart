import 'package:cloud_firestore/cloud_firestore.dart';

class TripDatabasehelper {
  final _firestore = FirebaseFirestore.instance.collection('trips');

  Future<void> addTrip(Map<String, dynamic> tripData) async {
    try {
      await _firestore.add(tripData);
    } catch (e) {
      print('Error adding trip: $e');
    }
  }

  Future<void> updateTrip(String tripId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.doc(tripId).update(updatedData);
    } catch (e) {
      print('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.doc(tripId).delete();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  Stream<QuerySnapshot> getTrips() {
    return _firestore.snapshots();
  }
}