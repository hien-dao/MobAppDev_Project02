import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ActivityDatabaseHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _collection(String tripId) {
    return _db.collection('trips').doc(tripId).collection('activities');
  }

  Future<String> addActivity(String tripId, Map<String, dynamic> data) async {
    final docRef = await _collection(tripId).add(data);
    return docRef.id;
  }

  Future<void> updateActivity(
    String tripId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    await _collection(tripId).doc(activityId).update(data);
  }

// ---------------- DELETE (WITH IMAGE CLEANUP) ----------------
  Future deleteActivity(String tripId, String activityId,) async {
    final docRef = _collection(tripId).doc(activityId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();

      // delete image if exists
      if (data != null && data['imageUrl'] != null) {
        try {
          await _storage.refFromURL(data['imageUrl']).delete();
        } catch (e) {
          print("Failed to delete image: $e");
        }
      }
    }

    await docRef.delete();

  }

  // ---------------- UPLOAD IMAGE ----------------
  Future<String> uploadActivityImage({
    required String tripId,
    required String activityId,
    required File file,
  }) async {
    print("Uploading for activityId: $activityId");

    if (activityId.isEmpty) {
      throw Exception("Invalid activityId");
    }

    final ref = _storage
        .ref()
        .child('trips')
        .child(tripId)
        .child('activities')
        .child('$activityId.jpg');

    print("Uploading to path: ${ref.fullPath}");

    final uploadTask = await ref.putFile(file);

    final url = await uploadTask.ref.getDownloadURL();

    print("UPLOAD SUCCESS: $url");
    print("tripId: $tripId");
    print("activityId: $activityId");
    print("file exists: ${await file.exists()}");
    print("storage path: trips/$tripId/activities/$activityId.jpg");

    return url;
  }

  // ---------------- SET IMAGE URL ----------------
  Future setActivityImage(
    String tripId,
    String activityId,
    String imageUrl,
    ) async {
    await _collection(tripId).doc(activityId).update({
      'imageUrl': imageUrl,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getActivities(String tripId) {
    return _collection(tripId).orderBy('order').snapshots();
  }
}