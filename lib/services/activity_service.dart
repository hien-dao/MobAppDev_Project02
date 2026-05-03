import '../models/activity.dart';
import 'activity_databasehelper.dart';

class ActivityService {
  final ActivityDatabaseHelper _db = ActivityDatabaseHelper();

  /// Add activity to a trip
  Future<void> addActivity({
    required String tripId,
    required Activity activity,
  }) async {
    await _db.addActivity(tripId, activity.toMap());
  }

  /// Update activity
  Future<void> updateActivity({
    required String tripId,
    required Activity activity,
  }) async {
    await _db.updateActivity(
      tripId,
      activity.id,
      activity.toMap(),
    );
  }

  /// Delete activity
  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    await _db.deleteActivity(tripId, activityId);
  }
}