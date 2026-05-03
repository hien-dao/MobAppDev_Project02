import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;

  String name;

  double latitude;
  double longitude;

  double cost;

  DateTime startTime;
  DateTime endTime;
  int durationMinutes;

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
    required this.durationMinutes,
    required this.order,
    required this.addedBy,
  });

  factory Activity.fromMap(Map<String, dynamic> data, String id) {
    return Activity(
      id: id,
      name: data['name'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      cost: (data['cost'] ?? 0).toDouble(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 120,
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
      'durationMinutes': durationMinutes,
      'order': order,
      'addedBy': addedBy,
    };
  }
}