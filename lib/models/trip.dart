import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  String name;

  DateTime startDate;
  DateTime endDate;

  String origin;
  String destinations;

  double totalCost;

  Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.origin,
    required this.destinations,
    required this.totalCost,
  });

  factory Trip.fromMap(Map<String, dynamic> data, String documentId) {
    return Trip(
      id: documentId,
      name: data['name'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      origin: data['origin'] ?? '',
      destinations: data['destinations'] ?? '',
      totalCost: (data['totalCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'origin': origin,
      'destinations': destinations,
      'totalCost': totalCost,
    };
  }
}