import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity.dart';
import '../services/activity_databasehelper.dart';
import '../services/auth_service.dart';
import '../services/place_service.dart';

class AddActivityScreen extends StatefulWidget {
  final String tripId;
  final int nextOrder;

  const AddActivityScreen({
    super.key,
    required this.tripId,
    required this.nextOrder,
  });

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController nameController = TextEditingController();

  final ActivityDatabaseHelper _activityDatabaseHelper = ActivityDatabaseHelper();
  final PlaceService _placeService = PlaceService();

  bool loading = false;
  bool searching = false;
  Timer? _debounce;

  List<Map<String, dynamic>> suggestions = [];

  Map<String, dynamic>? selectedPlace;

  // Estimated durations (in minutes) for different types of places
  int getEstimatedDuration(String name) {
    final lower = name.toLowerCase();

    if (lower.contains("museum")) return 180;
    if (lower.contains("tower")) return 90;
    if (lower.contains("park")) return 90;
    if (lower.contains("restaurant")) return 60;
    if (lower.contains("church")) return 60;
    if (lower.contains("landmark")) return 60;
    if (lower.contains("cinema")) return 150;

    return 90;
  }

  // ---------------- SEARCH PLACES ----------------
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    setState(() => searching = true);

    try {
      final results = await _placeService.searchPlaces(query);

      if (!mounted) return;

      setState(() {
        suggestions = results;
        searching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        suggestions = [];
        searching = false;
      });
    }
  }

  void selectPlace(Map<String, dynamic> place) {
    setState(() {
      selectedPlace = place;
      nameController.text = place['name'];
      suggestions = [];
    });
  }

  // ---------------- SAVE ----------------
  Future<void> addActivity() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => loading = true);

    final user = AuthService().currentUser;

    final docRef = FirebaseFirestore.instance
      .collection('trips')
      .doc(widget.tripId)
      .collection('activities')
      .doc(); // pre-generated ID

    final activity = Activity(
      id: docRef.id,
      name: name,
      latitude: selectedPlace?['lat'] ?? 0,
      longitude: selectedPlace?['lon'] ?? 0,
      cost: 0,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      durationMinutes: getEstimatedDuration(name),
      order: widget.nextOrder,
      day: 0,
      addedBy: user?.uid ?? '',
    );

    await _activityDatabaseHelper.addActivity(
      widget.tripId,
      activity.toMap(),
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Activity"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ---------------- INPUT ----------------
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Search activity (e.g. Eiffel Tower)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                _debounce = Timer(const Duration(milliseconds: 500), () {
                  searchPlaces(value);
                });
              },
            ),

            const SizedBox(height: 10),

            if (searching) const LinearProgressIndicator(),

            const SizedBox(height: 10),

            // ---------------- SUGGESTIONS ----------------
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final place = suggestions[index];

                  return ListTile(
                    title: Text(place['name']),
                    subtitle: Text(
                      "Lat: ${place['lat']}, Lng: ${place['lon']}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => selectPlace(place),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- SELECTED ----------------
            if (selectedPlace != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Selected: ${selectedPlace!['name']}",
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // ---------------- BUTTON ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addActivity,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Add Activity"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}