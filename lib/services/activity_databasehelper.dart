import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityDatabaseHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String tripId) {
    return _db.collection('trips').doc(tripId).collection('activities');
  }

  Future<void> addActivity(String tripId, Map<String, dynamic> data) async {
    await _collection(tripId).add(data);
  }

  Future<void> updateActivity(
    String tripId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    await _collection(tripId).doc(activityId).update(data);
  }

  Future<void> deleteActivity(String tripId, String activityId) async {
    await _collection(tripId).doc(activityId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getActivities(String tripId) {
    return _collection(tripId).orderBy('order').snapshots();
  }
}