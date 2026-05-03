import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;

  String name;

  double latitude;
  double longitude;

  double cost;

  DateTime startTime;
  DateTime endTime;

  int order; // position in itinerary

  String addedBy; // userId

  Activity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.cost,
    required this.startTime,
    required this.endTime,
    required this.order,
    required this.addedBy,
  });

  factory Activity.fromMap(Map<String, dynamic> data, String documentId) {
    return Activity(
      id: documentId,
      name: data['name'] ?? '',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      order: data['order'] ?? 0,
      addedBy: data['addedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'cost': cost,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'order': order,
      'addedBy': addedBy,
    };
  }
}