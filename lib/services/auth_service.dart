import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<UserCredential> createAccount(String firstName, String lastName, String email, String username, String password) async {
    try {

      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password, // Use the provided password
      );

      // Add additional user info to Firestore
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
      rethrow; // Rethrow the error to be handled by the caller
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
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during sign-out: $e');
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  // Check if username is unique
  Future<bool> isUsernameUnique(String username) async {
    try {
      final querySnapshot = await _usersCollection.where('username', isEqualTo: username).get();
      return querySnapshot.docs.isEmpty; // True if no user with the same username exists
    } catch (e) {
      print('Error checking username uniqueness: $e');
      return false; // Assume not unique if there's an error
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
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

    Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
      await _usersCollection.doc(user!.uid).delete(); // Remove user data from Firestore
    } catch (e) {
      print('Error deleting account: $e');
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  User? get currentUser => _auth.currentUser;
}