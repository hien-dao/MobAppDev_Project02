import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityDatabaseHelper {
  CollectionReference<Map<String, dynamic>> activityCollection(String tripId) {
    return FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('itinerary');
  }

  Future<void> addActivity(String tripId, Map<String, dynamic> data) async {
    await activityCollection(tripId).add(data);
  }

  Future<void> updateActivity(String tripId, String activityId, Map<String, dynamic> data) async {
    await activityCollection(tripId).doc(activityId).update(data);
  }

  Future<void> deleteActivity(String tripId, String activityId) async {
    await activityCollection(tripId).doc(activityId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getActivities(String tripId) {
    return activityCollection(tripId)
        .orderBy('order')
        .snapshots();
  }
}