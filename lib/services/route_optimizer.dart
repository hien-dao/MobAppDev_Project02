import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/activity.dart';

class RouteOptimizer {
  Future<int> getTravelTimeMinutes({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) async {
    final url =
        "http://router.project-osrm.org/route/v1/driving/"
        "$lng1,$lat1;$lng2,$lat2?overview=false";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final durationSeconds =
            data['routes'][0]['duration']; // seconds

        return (durationSeconds / 60).round(); // convert to minutes
      }
    } catch (e) {
      print("OSRM error: $e");
    }

    return 15; // fallback travel time
  }

  Future<List<Activity>> optimize(List<Activity> activities) async {
    if (activities.length <= 2) return activities;

    List<Activity> optimized = [activities.first];
    List<Activity> remaining = List.from(activities)..removeAt(0);

    while (remaining.isNotEmpty) {
      final last = optimized.last;

      Activity? nearest;
      int bestTime = 999999;

      for (final candidate in remaining) {
        final time = await getTravelTimeMinutes(
          lat1: last.latitude,
          lng1: last.longitude,
          lat2: candidate.latitude,
          lng2: candidate.longitude,
        );

        if (time < bestTime) {
          bestTime = time;
          nearest = candidate;
        }
      }

      optimized.add(nearest!);
      remaining.remove(nearest);
    }

    return optimized;
  }
}