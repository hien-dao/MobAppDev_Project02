import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String username;
  final DateTime createdAt;

  User({required this.id, required this.firstname, required this.lastname, required this.email, required this.username, required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      username: json['username'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'username': username,
      'createdAt': createdAt,
    };
  }
}