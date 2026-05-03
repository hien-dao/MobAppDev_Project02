import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip.dart';
import '../models/activity.dart';

import '../services/activity_databasehelper.dart';
import '../services/route_optimizer.dart';
import '../services/itinerary_service.dart';

import 'add_activity_screen.dart';

class ActivityScreen extends StatefulWidget {
  final Trip trip;

  const ActivityScreen({
    super.key,
    required this.trip,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final ActivityDatabaseHelper _db = ActivityDatabaseHelper();
  final RouteOptimizer optimizer = RouteOptimizer();
  final ItineraryScheduler scheduler = ItineraryScheduler();

  int getNextOrder(List<Activity> activities) {
    if (activities.isEmpty) return 0;
    activities.sort((a, b) => a.order.compareTo(b.order));
    return activities.last.order + 1;
  }

  // ---------------- BUILD LIST ----------------
  List<Activity> buildOptimizedList(List<Activity> activities) {
    if (activities.isEmpty) return [];
    return optimizer.optimize(activities);
  }

  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Drag to reorder your activities",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ---------------- FAB ----------------
      floatingActionButton: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.getActivities(widget.trip.id),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          final activities = docs
              .map((d) => Activity.fromMap(d.data(), d.id))
              .toList();

          final nextOrder = getNextOrder(activities);

          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddActivityScreen(
                    tripId: widget.trip.id,
                    nextOrder: nextOrder,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          );
        },
      ),

      // ---------------- BODY ----------------
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.getActivities(widget.trip.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No activities yet"));
          }

          // 1. Convert Firestore → Activity list
          final activities = docs
              .map((doc) => Activity.fromMap(doc.data(), doc.id))
              .toList();

          // 2. Optimize order (distance)
          activities.sort((a, b) => a.order.compareTo(b.order));

          // 3. Schedule time (async)
          return FutureBuilder<List<Activity>>(
            future: scheduler.schedule(
              activities: activities,
              tripStart: DateTime(
                widget.trip.startDate.year,
                widget.trip.startDate.month,
                widget.trip.startDate.day,
                9, // start at 9 AM
              ),
            ),
            builder: (context, scheduleSnapshot) {
              if (!scheduleSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final scheduled = scheduleSnapshot.data!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return ReorderableListView.builder(
                    itemCount: scheduled.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) newIndex--;

                      final item = activities.removeAt(oldIndex);
                      activities.insert(newIndex, item);

                      // 🔥 update order in memory
                      for (int i = 0; i < activities.length; i++) {
                        activities[i].order = i;
                      }

                      // 🔥 save to Firebase
                      for (final a in activities) {
                        await _db.updateActivity(
                          widget.trip.id,
                          a.id,
                          a.toMap(),
                        );
                      }

                      setState(() {});
                    },

                    itemBuilder: (context, index) {
                      final a = scheduled[index];

                      return Card(
                        key: ValueKey(a.id), // REQUIRED
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text("${index + 1}"),
                          ),
                          title: Text(a.name),
                          subtitle: Text(
                            "${formatTime(a.startTime)} - ${formatTime(a.endTime)}",
                          ),
                          trailing: const Icon(Icons.drag_handle), // UX hint
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}