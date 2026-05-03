import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip.dart';
import '../models/activity.dart';
import '../services/activity_databasehelper.dart';
import 'add_activity_screen.dart';

class ActivityScreen extends StatefulWidget {
  final Trip trip;

  const ActivityScreen({
    super.key,
    required this.trip
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final ActivityDatabaseHelper _db = ActivityDatabaseHelper();

  int getNextOrder(List<Activity> activities) {
    if (activities.isEmpty) return 0;

    activities.sort((a, b) => a.order.compareTo(b.order));
    return activities.last.order + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activities"),
      ),

      floatingActionButton: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.getActivities(widget.trip.id),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          final activities = docs.map((d) {
            return Activity.fromMap(d.data(), d.id);
          }).toList();

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

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.getActivities(widget.trip.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No activities yet"));
          }

          final activities = docs.map((doc) {
            return Activity.fromMap(doc.data(), doc.id);
          }).toList();

          activities.sort((a, b) => a.order.compareTo(b.order));

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final a = activities[index];

              return ListTile(
                leading: Text("${a.order + 1}"),
                title: Text(a.name),
              );
            },
          );
        },
      ),
    );
  }
}