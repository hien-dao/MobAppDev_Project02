import '../models/activity.dart';

class ItineraryService {
  List<Activity> buildSchedule(List<Activity> activities) {
    activities.sort((a, b) => a.order.compareTo(b.order));

    DateTime currentTime = DateTime(2026, 1, 1, 9, 0); // start 9AM

    List<Activity> scheduled = [];

    for (final activity in activities) {
      final start = currentTime;
      final end = start.add(Duration(minutes: activity.durationMinutes));

      activity.startTime = start;
      activity.endTime = end;

      scheduled.add(activity);

      currentTime = end.add(const Duration(minutes: 30)); // travel buffer
    }

    return scheduled;
  }
}