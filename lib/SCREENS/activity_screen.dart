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

  List<Activity> _activities = [];

  // ---------------- ORDER HELP ----------------
  int getNextOrder(List<Activity> activities) {
    if (activities.isEmpty) return 0;
    activities.sort((a, b) => a.order.compareTo(b.order));
    return activities.last.order + 1;
  }

  // ---------------- FORMAT TIME ----------------
  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // ---------------- OPTIMIZE ROUTE ----------------
  Future<void> optimizeRoute() async {
    if (_activities.isEmpty) return;

    final optimized = await optimizer.optimize(_activities);

    for (int i = 0; i < optimized.length; i++) {
      optimized[i].order = i;
    }

    await Future.wait(
      optimized.map(
        (a) => _db.updateActivity(
          widget.trip.id,
          a.id,
          a.toMap(),
        ),
      ),
    );

    setState(() {
      _activities = optimized;
    });
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Activities",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: "Auto Optimize Route",
            onPressed: optimizeRoute,
          ),
        ],
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

          // convert firestore → model
          _activities = docs
              .map((doc) => Activity.fromMap(doc.data(), doc.id))
              .toList();

          // sort by order
          _activities.sort((a, b) => a.order.compareTo(b.order));

          return FutureBuilder<List<Activity>>(
            future: scheduler.schedule(
              activities: _activities,
              tripStart: DateTime(
                widget.trip.startDate.year,
                widget.trip.startDate.month,
                widget.trip.startDate.day,
                9, // 9 AM start
              ),
            ),
            builder: (context, scheduleSnapshot) {
              final scheduled =
                  scheduleSnapshot.data ?? _activities;

              return ReorderableListView.builder(
                itemCount: _activities.length,

                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex--;

                  final item = _activities.removeAt(oldIndex);
                  _activities.insert(newIndex, item);

                  for (int i = 0; i < _activities.length; i++) {
                    _activities[i].order = i;
                  }

                  await Future.wait(
                    _activities.map(
                      (a) => _db.updateActivity(
                        widget.trip.id,
                        a.id,
                        a.toMap(),
                      ),
                    ),
                  );

                  setState(() {});
                },

                itemBuilder: (context, index) {
                  final a = scheduled[index];

                  return Card(
                    key: ValueKey(a.id),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),
                      title: Text(a.name),
                      subtitle: Text(
                        "${formatTime(a.startTime)} - ${formatTime(a.endTime)}",
                      ),
                      trailing: const Icon(Icons.drag_handle),
                    ),
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