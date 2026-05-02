import 'package:flutter/material.dart';

import '../models/trip.dart';

import '../services/auth_service.dart';
import '../services/trip_databasehelper.dart';

import 'firstscreen.dart';
import 'addtrip.dart';

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

  void rebuildTripList() {
    setState(() {
      tripStream = TripDatabasehelper().getTrips();
    });
  }

  Future<void> logoutUser() async {
    await AuthService().signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
    );
  }

  Future<void> openAddTripPage() async {
    final addedTrip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTrip(
          rebuildMainScreen: rebuildTripList,
        ),
      ),
    );

    if (addedTrip == true && mounted) {
      rebuildTripList();
    }
  }

  Future<void> openEditTripPage(Trip trip) async {
    final updatedTrip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTrip(
          rebuildMainScreen: rebuildTripList,
          tripToEdit: trip,
        ),
      ),
    );

    if (updatedTrip == true && mounted) {
      rebuildTripList();
    }
  }

  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$month/$day/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logoutUser,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openAddTripPage,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          const SizedBox(height: 30),

          const Text(
            'Home Page',
            style: TextStyle(fontSize: 24),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<Trip>>(
              stream: tripStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No trips yet!'),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final trip = items[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          trip.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${trip.origin} to ${trip.destination}\n'
                          '${formatDate(trip.startDate)} - ${formatDate(trip.endDate)}\n'
                          'Cost: \$${trip.totalCost.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.edit),
                        onTap: () {
                          openEditTripPage(trip);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}