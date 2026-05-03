import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeNotifications() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    if (token != null) {
      await saveTokenToCurrentUser(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveTokenToCurrentUser(newToken);
    });
  }

  Future<void> saveTokenToCurrentUser(String token) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}
