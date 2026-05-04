import 'dart:io';
import 'package:image_picker/image_picker.dart';
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

  // ---------------- MOVE ACTIVITY ----------------
  Future<void> moveActivity(Activity dragged, Activity target) async {
    setState(() {
      _activities.removeWhere((a) => a.id == dragged.id);

      final targetIndex =
        _activities.indexWhere((a) => a.id == target.id);

      dragged.day = target.day;

      _activities.insert(targetIndex, dragged);

      for (int i = 0; i < _activities.length; i++) {
        _activities[i].order = i;
      }
    });

    await Future.wait(
      _activities.map(
        (a) => _db.updateActivity(
          widget.trip.id,
          a.id,
          a.toMap(),
        ),
      ),
    );
  }

  // ---------------- MOVE TO DAY END ----------------
  Future<void> moveToDayEnd(Activity dragged, int day) async {
    setState(() {
      _activities.removeWhere((a) => a.id == dragged.id);


      dragged.day = day;

      _activities.add(dragged);

      for (int i = 0; i < _activities.length; i++) {
        _activities[i].order = i;
      }
    });

    await Future.wait(
      _activities.map(
        (a) => _db.updateActivity(
          widget.trip.id,
          a.id,
          a.toMap(),
        ),
      ),
    );
  }

  // ---------------- ACTIVITY TILE ----------------
  Widget buildActivityTile(Activity a) {
    print("IMAGE URL: ${a.imageUrl}");
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => pickAndUploadImage(a),
          child: a.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    a.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.add_a_photo),
                ),
        ),
        title: Text(a.name),
        subtitle: Text(
          "${formatTime(a.startTime)} - ${formatTime(a.endTime)}",
        ),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }

  // ---------------- DAY SECTION ----------------
  Widget buildDaySection(int day, List<Activity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Day ${day + 1}",
              style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              ),
            ),
          ),


        ...activities.map((a) {
          return LongPressDraggable<Activity>(
            data: a,
            feedback: Material(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(a.name),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: buildActivityTile(a),
            ),
            child: DragTarget<Activity>(
              onAccept: (dragged) => moveActivity(dragged, a),
              builder: (context, candidateData, rejectedData) {
                return buildActivityTile(a);
              },
            ),
          );
        }),

        // Drop at end of day
        DragTarget<Activity>(
          onAccept: (dragged) => moveToDayEnd(dragged, day),
          builder: (context, _, __) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text(
                  "Drop here to add to this day",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ],
    );


  }

  // IMAGE PICKER
  bool _isUploading = false;

  Future<void> pickAndUploadImage(Activity activity) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final url = await _db.uploadActivityImage(
        tripId: widget.trip.id,
        activityId: activity.id,
        file: File(picked.path),
      );

      print("GOT URL: $url");

      await _db.setActivityImage(
        widget.trip.id,
        activity.id,
        url,
      );
    } catch (e) {
      print("Upload error: $e");
    }

    setState(() => _isUploading = false);
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
    body: Stack(
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _db.getActivities(widget.trip.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No activities yet"));
          }

          _activities = docs
              .map((doc) => Activity.fromMap(doc.data(), doc.id))
              .toList();

          _activities.sort((a, b) => a.order.compareTo(b.order));

          return FutureBuilder<List<Activity>>(
            future: scheduler.schedule(
              activities: _activities,
              tripStart: DateTime(
                widget.trip.startDate.year,
                widget.trip.startDate.month,
                widget.trip.startDate.day,
              ),
              tripEnd: DateTime(
                widget.trip.endDate.year,
                widget.trip.endDate.month,
                widget.trip.endDate.day,
              ),
            ),
            builder: (context, scheduleSnapshot) {
              final scheduled =
                  scheduleSnapshot.data ?? _activities;

              // GROUP BY DAY
              Map<int, List<Activity>> grouped = {};

              for (var a in scheduled) {
                grouped.putIfAbsent(a.day, () => []).add(a);
              }

              return ListView(
                children: grouped.entries.map((entry) {
                  final day = entry.key;
                  final activities = entry.value;

                  return buildDaySection(day, activities);
                }).toList(),
              );
            },
          );
        },
      ),
      if (_isUploading)
        Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    ),
  );
  }
}
