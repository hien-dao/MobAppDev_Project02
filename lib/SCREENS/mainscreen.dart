import 'package:flutter/material.dart';

import '../models/trip.dart';

import '../services/auth_service.dart';
import '../services/trip_databasehelper.dart';

import 'package:proj2/SCREENS/firstscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  Stream<List<Trip>>? tripStream;

  @override
  void initState() {
    super.initState();
    tripStream = TripDatabasehelper().getTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FirstScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home Page',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            //Main screen features will be updated
            Expanded(
              child: StreamBuilder<List<Trip>>(
                stream: tripStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No trip yet!')
                      );
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final trip = items[index];
                      return ListTile(
                        title: Text(trip.destination),
                        subtitle: Text('From ${trip.startDate} to ${trip.endDate}'),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}