import '../models/activity.dart';
import 'route_optimizer.dart';

class ItineraryScheduler {
  final RouteOptimizer _routeOptimizer = RouteOptimizer();

  Future<List<Activity>> schedule({
    required List<Activity> activities,
    required DateTime tripStart,
  }) async {
    if (activities.isEmpty) return [];

    DateTime currentTime = tripStart;

    for (int i = 0; i < activities.length; i++) {
      final a = activities[i];

      // add travel time from previous activity
      if (i > 0) {
        final prev = activities[i - 1];

        final travelMinutes = await _routeOptimizer.getTravelTimeMinutes(
          lat1: prev.latitude,
          lng1: prev.longitude,
          lat2: a.latitude,
          lng2: a.longitude,
        );

        currentTime = currentTime.add(
          Duration(minutes: travelMinutes),
        );
      }

      a.startTime = currentTime;

      currentTime = currentTime.add(
        Duration(minutes: a.durationMinutes),
      );

      a.endTime = currentTime;
    }

    return activities;
  }
}