import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip.dart';
import '../models/activity.dart';
import '../services/activity_databasehelper.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activities"),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.getActivities(widget.trip.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No activities yet"),
            );
          }

          final activities = docs.map((doc) {
            return Activity.fromMap(doc.data(), doc.id);
          }).toList();

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final a = activities[index];

              return ListTile(
                title: Text(a.name),
                subtitle: Text(
                  "Order: ${a.order} | Cost: \$${a.cost}",
                ),

                trailing: const Icon(Icons.drag_handle),
              );
            },
          );
        },
      ),
    );
  }
}