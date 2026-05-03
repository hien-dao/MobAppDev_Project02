import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<UserCredential> createAccount(
    String firstName,
    String lastName,
    String email,
    String username,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _usersCollection.doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      print('Error creating account: $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error during sign-in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during sign-out: $e');
      rethrow;
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username uniqueness: $e');
      return false;
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await _usersCollection.doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final trimmedQuery = query.trim();

      if (trimmedQuery.isEmpty) return [];

      final snapshot = await _usersCollection
          .where('username', isGreaterThanOrEqualTo: trimmedQuery)
          .where('username', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'uid': doc.id,
          'username': data['username'] ?? '',
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<Map<String, String>> getUsernamesByIds(List<String> uids) async {
    try {
      final Map<String, String> result = {};

      for (final uid in uids) {
        final doc = await _usersCollection.doc(uid).get();

        if (doc.exists) {
          final data = doc.data();
          result[uid] = data?['username'] ?? uid;
        }
      }

      return result;
    } catch (e) {
      print('Error fetching usernames: $e');
      return {};
    }
  }

  Future<String?> getCurrentUsername() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _usersCollection.doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['username'];
      }

      return null;
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  User? get currentUser => _auth.currentUser;
}
