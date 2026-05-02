import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/trip_databasehelper.dart';

class AddTrip extends StatefulWidget {
  final VoidCallback rebuildMainScreen;

  const AddTrip({
    super.key,
    required this.rebuildMainScreen,
  });

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  final nameController = TextEditingController();
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final totalCostController = TextEditingController();

  bool loading = false;

  Future<void> addTrip() async {
    final name = nameController.text.trim();
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();
    final startDateText = startDateController.text.trim();
    final endDateText = endDateController.text.trim();
    final totalCostText = totalCostController.text.trim();

    if (name.isEmpty ||
        origin.isEmpty ||
        destination.isEmpty ||
        startDateText.isEmpty ||
        endDateText.isEmpty ||
        totalCostText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
        ),
      );
      return;
    }

    DateTime startDate;
    DateTime endDate;
    double totalCost;

    try {
      startDate = DateTime.parse(startDateText);
      endDate = DateTime.parse(endDateText);
      totalCost = double.parse(totalCostText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use dates like 2026-05-02 and cost like 150.00'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final newTrip = Trip(
        id: '',
        name: name,
        startDate: startDate,
        endDate: endDate,
        origin: origin,
        destination: destination,
        totalCost: totalCost,
      );

      await TripDatabasehelper().addTrip(newTrip.toMap());

      widget.rebuildMainScreen();

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding trip: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    originController.dispose();
    destinationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    totalCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Trip'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: originController,
              decoration: const InputDecoration(
                labelText: 'Origin',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: startDateController,
              decoration: const InputDecoration(
                labelText: 'Start Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: endDateController,
              decoration: const InputDecoration(
                labelText: 'End Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: totalCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Cost',
                hintText: 'Example: 150.00',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : addTrip,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Add Trip'),
            ),
          ],
        ),
      ),
    );
  }
}