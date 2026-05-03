import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';

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
  final ActivityService _service = ActivityService();

  bool loading = false;

  Future<void> addActivity() async {
    final name = nameController.text.trim();

    if (name.isEmpty) return;

    setState(() => loading = true);

    final user = AuthService().currentUser;

    final activity = Activity(
      id: '',
      name: name,
      latitude: 0,
      longitude: 0,
      cost: 0,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      order: widget.nextOrder,
      addedBy: user?.uid ?? '',
    );

    await _service.addActivity(
      tripId: widget.tripId,
      activity: activity,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Activity name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addActivity,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}