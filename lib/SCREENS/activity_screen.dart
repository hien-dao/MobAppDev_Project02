import 'package:flutter/material.dart';

import '../models/trip.dart';

class ActivityScreen extends StatelessWidget {
  final Trip trip;

  const ActivityScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
      ),
      body: const Center(
        child: Text("Activity Page (WIP)"),
      ),
    );
  }
}