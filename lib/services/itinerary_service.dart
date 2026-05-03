import '../models/activity.dart';
import 'route_optimizer.dart';

class ItineraryScheduler {
  final RouteOptimizer _routeOptimizer = RouteOptimizer();

  Future<List<Activity>> schedule({
    required List<Activity> activities,
    required DateTime tripStart,
    required DateTime tripEnd,
  }) async {
    if (activities.isEmpty) return [];

    const int dayStartHour = 9;
    const int dayEndHour = 18;

    final maxDays = tripEnd.difference(tripStart).inDays + 1;

    int currentDay = 0;

    DateTime currentTime = DateTime(
      tripStart.year,
      tripStart.month,
      tripStart.day,
      dayStartHour,
    );

    for (int i = 0; i < activities.length; i++) {
      final a = activities[i];

      if (i > 0) {
        final prev = activities[i - 1];

        final travelMinutes = await _routeOptimizer.getTravelTimeMinutes(
          lat1: prev.latitude,
          lng1: prev.longitude,
          lat2: a.latitude,
          lng2: a.longitude,
        );

        currentTime = currentTime.add(Duration(minutes: travelMinutes));
      }

      final activityEnd = currentTime.add(
        Duration(minutes: a.durationMinutes),
      );

      final endOfDay = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        dayEndHour,
      );

      if (activityEnd.isAfter(endOfDay)) {
        // 🚨 limit reached
        if (currentDay >= maxDays - 1) {
          a.day = -1; // unscheduled
          continue;
        }

        currentDay++;

        currentTime = DateTime(
          tripStart.year,
          tripStart.month,
          tripStart.day,
          dayStartHour,
        ).add(Duration(days: currentDay));
      }

      a.day = currentDay;
      a.startTime = currentTime;

      currentTime = currentTime.add(
        Duration(minutes: a.durationMinutes),
      );

      a.endTime = currentTime;
    }

    return activities;
  }
}